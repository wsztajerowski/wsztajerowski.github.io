# Fails the build when a talk, project or the profile is malformed, so a bad
# data PR goes red before it can be merged instead of rendering a broken card.
#
# It checks the front matter as written, not doc.data: Jekyll fills in some
# keys on its own (a missing `title` becomes the file name), which would hide
# exactly the mistakes this is here to catch.

require "yaml"
require "date"

module DataValidation
  URL = %r{\Ahttps?://[^\s/$.?#][^\s]*\z}

  SCHEMAS = {
    "talks" => {
      required: %w[title order slides pdf repo],
      optional: %w[subtitle recording tags draft],
      urls: %w[slides pdf repo recording],
      order_required: true,
    },
    "projects" => {
      required: %w[title repo],
      optional: %w[order homepage tags draft],
      urls: %w[repo homepage],
      order_required: false,
    },
  }.freeze

  module_function

  def front_matter(path)
    text = File.read(path)
    match = text.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
    return [nil, text] unless match

    [YAML.safe_load(match[1], permitted_classes: [Date]) || {}, match[2]]
  end

  def check_collection(site, name, schema, errors)
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

      errors << "#{file}: the body (the text under the front matter) is empty" if body.strip.empty?
    end

    orders.each do |order, files|
      errors << "#{files.join(' and ')}: share `order: #{order}` — each must be unique" if files.size > 1
    end
  end

  def check_profile(site, errors)
    profile = site.data["profile"]
    return errors << "_data/profile.yml is missing" unless profile.is_a?(Hash)

    %w[name short_bio long_bio photo photo_download].each do |key|
      errors << "_data/profile.yml: `#{key}` is required" if profile[key].to_s.strip.empty?
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
  DataValidation::SCHEMAS.each { |name, schema| DataValidation.check_collection(site, name, schema, errors) }
  DataValidation.check_profile(site, errors)
  next if errors.empty?

  message = "Site data is invalid:\n" + errors.map { |e| "  - #{e}" }.join("\n")
  raise Jekyll::Errors::FatalException, message
end
