# frozen_string_literal: true

  class EditorJs
    class Block
      class External < EditorJs::Block
        ONLY_FILE_NAME_REGEXP = %r{(.+?)(\.[^.]*$|$)}.freeze
        DEFAULT_URL_PROTOCOL = "http://".freeze
        NOT_VAILD_URL_REGEXP = %r{^(\/\/|\/)}.freeze

        attr_reader :name, :caption

        def initialize(data)
          super(data)
          @caption = data["caption"]
          @name = build_name
        end

        protected

        def build_url
          with_default_protocol
        end

        def parse_file_name(mode = :with_extension)
          file_name = url.to_s.split('/')[-1]
          return file_name if mode == :with_extension

          ONLY_FILE_NAME_REGEXP =~ file_name
          return file_name unless $LAST_MATCH_INFO

          $LAST_MATCH_INFO[1]
        end

        def with_default_protocol
          url_valid? ? url : url.gsub(NOT_VAILD_URL_REGEXP, DEFAULT_URL_PROTOCOL)
        end

        def url_valid?
          url !~ NOT_VAILD_URL_REGEXP
        end
      end
    end
  end