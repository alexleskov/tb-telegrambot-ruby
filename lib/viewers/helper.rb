module Viewers
  module Helper
    def create_title(params)
      raise "Params is '#{params.class}'. Must be a Hash" unless params.is_a?(Hash)

      if params.keys.include?(:text)
        params[:text]
      else
        Breadcrumb.g(params[:object], params[:stages], params[:params])
      end
    end

    def action_buttons(back_button = true)
      build_approve_button + build_show_answers_button + build_to_section_button(back_button)
    end

    def button_sign(cont_type)
      "#{attach_emoji(cont_type)} #{name} #{attach_emoji(status)}"
    end

    private

    def build_approve_button
      course_session.active? ? approve_button : []
    end

    def build_to_section_button(back_button)
      back_button ? section.back_button : []
    end

    def build_show_answers_button
      answers && !answers.empty? ? show_answer_button : []
    end

  end
end