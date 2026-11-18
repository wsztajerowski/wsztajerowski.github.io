# Fails the build when a talk, project, the profile or the interface text is
# malformed, so a bad data PR goes red before it can be merged instead of
# rendering a broken or half-translated card.
#
# Talks and projects are lists in _data/talks.yml and _data/projects.yml; the
# site shows them in the order written, so there is no `order` field.

require "date"

module DataValidation
  URL = %r{\Ahttps?://[^\s/$.?#][^\s]*\z}

  # `localized`: a map with one non-empty text per site language.
  # `translatable`: either that map, or plain text for words that stay the
  # same in every language (a product name, a talk's original title).
  SCHEMAS = {
    "talks" => {
      required: %w[title],
      optional: %w[subtitle slides pdf repo abstract recordings tags],
      urls: %w[slides pdf repo],
      localized: %w[abstract],
      translatable: %w[title subtitle],
    },
    "projects" => {
      required: %w[title repo description],
      optional: %w[homepage tags],
      urls: %w[repo homepage],
      localized: %w[description],
      translatable: %w[title],
    },
  }.freeze

  module_function

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

  # How an entry is named in error messages: its position, plus its title
  # when it has one, e.g. `_data/talks.yml, entry 3 (MongoDB in a nutshell)`.
  def entry_label(name, data, index)
    title = data["title"].is_a?(Hash) ? data["title"].values.first : data["title"]
    label = "_data/#{name}.yml, entry #{index + 1}"
    title.to_s.strip.empty? ? label : "#{label} (#{title})"
  end

  def check_list(site, name, schema, langs, errors)
    list = site.data[name]
    return errors << "_data/#{name}.yml is missing" if list.nil?
    return errors << "_data/#{name}.yml must be a list: start each entry with `- title: …`" unless list.is_a?(Array)

    list.each_with_index do |data, index|
      unless data.is_a?(Hash)
        errors << "_data/#{name}.yml, entry #{index + 1}: must be a set of fields starting with `- title: …`"
        next
      end
      file = entry_label(name, data, index)

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

      if data.key?("recordings")
        recs = data["recordings"]
        if !recs.is_a?(Array) || recs.empty?
          errors << "#{file}: `recordings` must be a list, e.g.\n" \
                    "      recordings:\n        - event: JUG Łódź\n          date: 2025-03-12\n          url: https://www.youtube.com/watch?v=…"
        else
          recs.each_with_index do |rec, i|
            unless rec.is_a?(Hash) && rec["url"].to_s.match?(URL)
              errors << "#{file}: recordings[#{i}] needs an http(s) `url`"
              next
            end
            if rec.key?("date") && !rec["date"].is_a?(Date)
              errors << "#{file}: recordings[#{i}] `date` must be YYYY-MM-DD, got #{rec['date'].inspect}"
            end
            extra = rec.keys - %w[event date url]
            errors << "#{file}: recordings[#{i}] has unknown field(s) #{extra.join(', ')} — allowed: event, date, url" if extra.any?
          end
        end
      end

      if data.key?("tags") && !(data["tags"].is_a?(Array) && data["tags"].all? { |t| t.is_a?(String) })
        errors << "#{file}: `tags` must be a list of strings, e.g. [JUnit, JMH]"
      end
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
  DataValidation::SCHEMAS.each { |name, schema| DataValidation.check_list(site, name, schema, langs, errors) }
  DataValidation.check_profile(site, langs, errors)
  next if errors.empty?

  message = "Site data is invalid:\n" + errors.map { |e| "  - #{e}" }.join("\n")
  raise Jekyll::Errors::FatalException, message
end
