# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class DemoMode
        class CourseSession < Teachbase::Bot::Strategies::Base::CourseSession
          def states
            interface.cs.menu(text: "#{Phrase.courses_list}\n\n#{I18n.t('about_courses_page')}").states.show
          end
        end
      end
    end
  end
end
