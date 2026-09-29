# Fails the build when a talk, project, the profile or the interface text is
# malformed, so a bad data PR goes red before it can be merged instead of
# rendering a broken or half-translated card.
#
# It checks the front matter as written, not doc.data: Jekyll fills in some
# keys on its own (a missing `title` becomes the file name), which would hide
# exactly the mistakes this is here to catch.

require "yaml"
require "date"

module DataValidation
  URL = %r{\Ahttps?://[^\s/$.?#][^\s]*\z}

  # `localized`: a map with one non-empty text per site language.
  # `translatable`: either that map, or plain text for words that stay the
  # same in every language (a product name, a talk's original title).
  SCHEMAS = {
    "talks" => {
      required: %w[title order slides pdf repo abstract],
      optional: %w[subtitle recording tags],
      urls: %w[slides pdf repo recording],
      localized: %w[abstract],
      translatable: %w[title subtitle],
      order_required: true,
    },
    "projects" => {
      required: %w[title repo description],
      optional: %w[order homepage tags],
      urls: %w[repo homepage],
      localized: %w[description],
      translatable: %w[title],
      order_required: false,
    },
  }.freeze

  module_function

  def front_matter(path)
    text = File.read(path)
    match = text.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
    return [nil, text] unless match

    [YAML.safe_load(match[1], permitted_classes: [Date]) || {}, match[2]]
  end

  def check_localized(file, key, value, langs, errors)
    unless value.is_a?(Hash)
      errors << "#{file}: `#{key}` needs one entry per language (#{langs.join(', ')}), e.g.\n" \
                "      #{key}:\n" + langs.map { |l| "        #{l}: …" }.join("\n")
      return
    end
    langs.each do |lang|
      errors << "#{file}: `#{key}.#{lang}` is missing or empty" if value[lang].to_s.strip.empty?
    end
    extra = value.keys - langs
    errors << "#{file}: `#{key}` has unknown language(s) #{extra.join(', ')} — the site speaks #{langs.join(', ')}" if extra.any?
  end

  def check_collection(site, name, schema, langs, errors)
    collection = site.collections[name]
    return errors << "_#{name}/ is missing" unless collection

    orders = Hash.new { |h, k| h[k] = [] }
    collection.docs.each do |doc|
      file = doc.relative_path
      data, body = front_matter(doc.path)
      unless data.is_a?(Hash)
        errors << "#{file}: no front matter (it must start with a --- block)"
        next
      end

      unknown = data.keys - schema[:required] - schema[:optional]
      errors << "#{file}: unknown field(s) #{unknown.join(', ')} — typo? " \
                "Allowed: #{(schema[:required] + schema[:optional]).join(', ')}" if unknown.any?

      schema[:required].each do |key|
        errors << "#{file}: `#{key}` is required" if data[key].nil? || data[key].to_s.strip.empty?
      end

      schema[:localized].each do |key|
        check_localized(file, key, data[key], langs, errors) unless data[key].nil?
      end
      schema[:translatable].each do |key|
        value = data[key]
        if value.is_a?(Hash)
          check_localized(file, key, value, langs, errors)
        elsif !value.nil? && !value.is_a?(String)
          errors << "#{file}: `#{key}` must be text, or one text per language"
        end
      end

      schema[:urls].each do |key|
        next if data[key].nil?

        errors << "#{file}: `#{key}` must be an http(s) URL, got #{data[key].inspect}" unless data[key].to_s.match?(URL)
      end

      if data.key?("order") || schema[:order_required]
        order = data["order"]
        if order.is_a?(Integer) && order.positive?
          orders[order] << file
        elsif !order.nil?
          errors << "#{file}: `order` must be a positive whole number, got #{order.inspect}"
        end
      end

      if data.key?("tags") && !(data["tags"].is_a?(Array) && data["tags"].all? { |t| t.is_a?(String) })
        errors << "#{file}: `tags` must be a list of strings, e.g. [JUnit, JMH]"
      end

      unless body.strip.empty?
        text_key = schema[:localized].last
        errors << "#{file}: text below the front matter is ignored — move it into `#{text_key}` (one entry per language)"
      end
    end

    orders.each do |order, files|
      errors << "#{files.join(' and ')}: share `order: #{order}` — each must be unique" if files.size > 1
    end
  end

  def check_i18n(i18n, errors)
    return errors << "_data/i18n.yml is missing" unless i18n.is_a?(Hash)

    langs = Array(i18n["languages"])
    return errors << "_data/i18n.yml: `languages` must list at least one language" if langs.empty?

    langs.each { |l| errors << "_data/i18n.yml: no `#{l}:` section for language #{l}" unless i18n[l].is_a?(Hash) }
    present = langs.select { |l| i18n[l].is_a?(Hash) }
    all_keys = present.flat_map { |l| i18n[l].keys }.uniq
    present.each do |l|
      missing = all_keys - i18n[l].keys
      errors << "_data/i18n.yml: `#{l}` is missing #{missing.join(', ')}" if missing.any?
      empty = i18n[l].select { |_, v| v.to_s.strip.empty? }.keys
      errors << "_data/i18n.yml: `#{l}` has empty #{empty.join(', ')}" if empty.any?
    end
    Array(i18n["tabs"]).each do |tab|
      next if present.all? { |l| i18n[l].key?("tab_#{tab['key']}") }

      errors << "_data/i18n.yml: tab `#{tab['key']}` needs a `tab_#{tab['key']}` label in every language"
    end
  end

  def check_profile(site, langs, errors)
    profile = site.data["profile"]
    return errors << "_data/profile.yml is missing" unless profile.is_a?(Hash)

    %w[name photo photo_download].each do |key|
      errors << "_data/profile.yml: `#{key}` is required" if profile[key].to_s.strip.empty?
    end

    bios = profile["bio"]
    if !bios.is_a?(Array) || bios.empty?
      errors << "_data/profile.yml: `bio` must be a list with one entry per language"
    else
      bios.each_with_index do |bio, i|
        missing = %w[lang tagline text].select { |key| !bio.is_a?(Hash) || bio[key].to_s.strip.empty? }
        errors << "_data/profile.yml: bio[#{i}] is missing #{missing.join(', ')}" if missing.any?
      end
      have = bios.select { |b| b.is_a?(Hash) }.map { |b| b["lang"] }.compact
      have.uniq.each do |lang|
        errors << "_data/profile.yml: bio language `#{lang}` appears more than once" if have.count(lang) > 1
      end
      (langs - have).each { |lang| errors << "_data/profile.yml: no bio for language `#{lang}`" }
    end
    Array(profile["links"]).each_with_index do |link, i|
      unless link.is_a?(Hash) && !link["label"].to_s.empty? && link["url"].to_s.match?(URL)
        errors << "_data/profile.yml: links[#{i}] needs a `label` and an http(s) `url`"
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  errors = []
  i18n = site.data["i18n"]
  DataValidation.check_i18n(i18n, errors)
  langs = i18n.is_a?(Hash) ? Array(i18n["languages"]) : []
  DataValidation::SCHEMAS.each { |name, schema| DataValidation.check_collection(site, name, schema, langs, errors) }
  DataValidation.check_profile(site, langs, errors)
  next if errors.empty?

  message = "Site data is invalid:\n" + errors.map { |e| "  - #{e}" }.join("\n")
  raise Jekyll::Errors::FatalException, message
end
