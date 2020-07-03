# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module ScormPackage
        def print_scorm_package(scorm_package)
          print_scorm_package_title(scorm_package)
          print_scorm_package_link(scorm_package)
          buttons = scorm_package.action_buttons
          menu_content_main(buttons: buttons) unless buttons.empty?
        end

        def print_scorm_package_link(scorm_package)
          answer.content.url(link: scorm_package.source, link_name: "#{I18n.t('open').capitalize}: #{scorm_package.name}")
        end

        def print_scorm_package_title(scorm_package)
          answer.text.send_out(create_title(object: scorm_package,
                                            stages: %i[contents title]), disable_notification: true)
        end
      end
    end
  end
end
