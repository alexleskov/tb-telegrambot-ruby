# frozen_string_literal: true

class Attribute
  SKIPPABLE_ATTRS = %i[id position created_at updated_at].freeze

  class << self
    def create(object_attr_names, lms_data, lms_attr_cnames = {})
      new(object_attr_names, lms_data, lms_attr_cnames).build_attributes
    end
  end

  attr_reader :object_attr_names, :lms_data, :lms_attr_cnames, :attributes

  def initialize(object_attr_names, lms_data, lms_attr_cnames = {})
    unless object_attr_names.is_a?(Array)
      raise "object_attr_names: '#{object_attr_names}' is #{object_attr_names.class}. Must be an Array"
    end
    raise "lms_data: #{lms_data} is #{lms_data.class}. Must be a Hash" unless lms_data.is_a?(Hash)

    @object_attr_names = object_attr_names
    @lms_data = lms_data
    @lms_attr_cnames = lms_attr_cnames
    @attributes = {}
  end

  def build_attributes
    replace_key_names if lms_attr_cnames && !lms_attr_cnames.empty?
    object_attr_names.each do |attr_name|
      next if lms_data[attr_name.to_s].nil? || SKIPPABLE_ATTRS.include?(attr_name.to_sym)

      attributes[attr_name.to_sym] = lms_data[attr_name.to_s]
    end
    attributes
  end

  private

  def replace_key_names
    lms_attr_cnames.each do |old_key, new_key|
      next unless lms_data[old_key]

      lms_data[new_key.to_s] = lms_data.delete(old_key)
    end
    lms_data
  end
end
