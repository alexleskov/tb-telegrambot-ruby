# frozen_string_literal: true

module EmojiAliaser
  class << self
    def white_check_mark
      Emoji.t(:white_check_mark)
    end

    def white_medium_small_square
      Emoji.t(:white_medium_small_square)
    end

    def arrow_forward
      Emoji.t(:arrow_forward)
    end

    def no_entry_sign
      Emoji.t(:no_entry_sign)
    end

    def x
      Emoji.t(:x)
    end

    def page_facing_up
      Emoji.t(:page_facing_up)
    end

    def clapper
      Emoji.t(:clapper)
    end

    def sound
      Emoji.t(:sound)
    end

    def camera
      Emoji.t(:camera)
    end

    def memo
      Emoji.t(:memo)
    end

    def bar_chart
      Emoji.t(:bar_chart)
    end

    def computer
      Emoji.t(:computer)
    end

    def green_book
      Emoji.t(:green_book)
    end

    def closed_book
      Emoji.t(:closed_book)
    end

    def round_pushpin
      Emoji.t(:round_pushpin)
    end

    def clock4
      Emoji.t(:clock4)
    end

    def notebook
      Emoji.t(:notebook)
    end

    def globe_with_meridians
      Emoji.t(:globe_with_meridians)
    end

    def open_file_folder
      Emoji.t(:open_file_folder)
    end

    def chart_with_upwards_trend
      Emoji.t(:chart_with_upwards_trend)
    end

    alias completed white_check_mark
    alias accepted white_check_mark
    alias passed white_check_mark

    alias checking clock4

    alias open open_file_folder

    alias section_unable no_entry_sign
    alias section_delayed no_entry_sign

    alias section_unpublish x
    alias declined x
    alias failed x

    alias materials page_facing_up
    alias material page_facing_up
    alias text page_facing_up
    alias table page_facing_up

    alias pdf notebook

    alias iframe globe_with_meridians

    alias video clapper
    alias youtube clapper
    alias vimeo clapper
    alias netology clapper

    alias audio sound

    alias image camera

    alias tasks memo
    alias task memo

    alias quizzes bar_chart
    alias quiz bar_chart

    alias scorm_packages computer
    alias scorm_package computer

    alias active green_book

    alias poll chart_with_upwards_trend
    alias polls chart_with_upwards_trend

    alias archived closed_book
  end
end
