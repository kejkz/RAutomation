module RAutomation
  module Adapter
    module MsUia
      class Control
        include WaitHelper
        include Locators

        # Creates the control object.
        # @note this method is not meant to be accessed directly
        # @param [RAutomation::Window] window this button belongs to.
        # @param [Hash] locators for searching the button.
        # @option locators [String, Regexp] :value Value (text) of the button
        # @option locators [String, Regexp] :class Internal class name of the button
        # @option locators [String, Fixnum] :id Internal ID of the button
        # @option locators [String, Fixnum] :index 0-based index to specify n-th button if all other criteria match
        # @see RAutomation::Window#button
        def initialize(window, locators)
          @window = window
          extract(locators)
        end

        #todo - replace with UIA version
        def hwnd
          Functions.control_hwnd(@window.hwnd, @locators)
        end

        def search_information
          info = UiaDll::SearchCriteria.from_locator(@window.hwnd, @locators)
          if info.how == 0
            info.how = :hwnd
            info.data = hwnd
          end
          info
        end

        #todo - replace with UIA version
        def click
          assert_enabled
          clicked = false
          wait_until do
            @window.activate
            @window.active? &&
                UiaDll::control_click(search_information) &&
                clicked = true # is clicked at least once

            block_given? ? yield : clicked && !exist?
          end
        end

        def exist?
          begin
            UiaDll::exists?(search_information) || !!hwnd
          rescue UnknownElementException
            false
          end
        end

        def enabled?
          !disabled?
        end

        #todo - replace with UIA version
        def disabled?
          Functions.unavailable?(hwnd)
        end

        #todo - replace with UIA version
        def focused?
          Functions.has_focus?(hwnd)
        end

        def focus
          assert_enabled
          uia_control = UiaDll::element_from_handle(hwnd)
          UiaDll::set_focus(uia_control)
        end

        def bounding_rectangle
          UiaDll::bounding_rectangle(search_information)
        end

        def visible?
          element = UiaDll::element_from_handle(hwnd)

          off_screen = FFI::MemoryPointer.new :int

          if UiaDll::is_offscreen(element, off_screen) == 0
            fail "Could not check element"
          end

#          puts "return #{off_screen.read_int}"
          if off_screen.read_int == 0
            return true
          end
          false
        end

        def matches_type?(*classes)
          classes.include? get_current_control_type
        end

        def get_current_control_type
          UiaDll::current_control_type(search_information)
        end

        def new_pid
          UiaDll::process_id(search_information)
        end

        def control_name
          UiaDll::name(search_information)
        end

        def control_class
          UiaDll::class_name(search_information)
        end

        alias_method :exists?, :exist?

        def assert_enabled
          raise "Cannot interact with disabled control #{@locators.inspect} on window #{@window.locators.inspect}!" if disabled?
        end

        def expand(which_item)
          UiaDll::expand_by_value search_information, which_item if which_item.is_a? String
          UiaDll::expand_by_index search_information, which_item if which_item.is_a? Integer
        end

        def collapse(which_item)
          UiaDll::collapse_by_value search_information, which_item if which_item.is_a? String
          UiaDll::collapse_by_index search_information, which_item if which_item.is_a? Integer
        end

      end
    end
  end
end
