# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class DemoMode
        class CourseSession < Teachbase::Bot::Strategies::CourseSession
          def states
            interface.cs.menu(text: "#{Emoji.t(:books)}<b>#{I18n.t('cs_list')}</b>\n\n#{I18n.t('about_courses_page')}").states.show
          end
        end
      end
    end
  end
end
