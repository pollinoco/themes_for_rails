require "spec_helper"

describe ThemesOnRails::ActionController do
  let(:controller)        { controller_class.new }
  let(:controller_class)  { Class.new }

  it "initializes with theme as string" do
    action_controller = ThemesOnRails::ActionController.new(controller, "theme_a")

    expect(action_controller.theme_name).to eq("theme_a")
  end

  it "initializes with theme as symbol method" do
    def controller.theme_resolver
      "theme_a"
    end
    action_controller = ThemesOnRails::ActionController.new(controller, :theme_resolver)

    expect(action_controller.theme_name).to eq("theme_a")
  end

  it "initializes with theme as symbol" do
    action_controller = ThemesOnRails::ActionController.new(controller, :theme_a)

    expect(action_controller.theme_name).to eq("theme_a")
  end

  it "initializes with theme as proc or lambda" do
    action_controller = ThemesOnRails::ActionController.new(controller, lambda { |con| "theme_a" })

    expect(action_controller.theme_name).to eq("theme_a")
  end

  it "initializes with theme as nil" do
    expect {
      ThemesOnRails::ActionController.new(controller, nil)
    }.to raise_error(ArgumentError)
  end

  it "#theme_view_path" do
    action_controller = ThemesOnRails::ActionController.new(controller, "theme_a")

    expect(action_controller.theme_view_path).to eq("#{Rails.root}/app/themes/theme_a/views")
  end

  describe ".apply_theme" do
    let(:controller_class) do
      Class.new do
        class << self
          attr_accessor :layout_args, :filter_method, :filter_options, :filter_block

          def layout(*args)
            @layout_args = args
          end

          def before_action(options = {}, &block)
            @filter_method = :before_action
            @filter_options = options
            @filter_block = block
          end

          def prepend_before_action(options = {}, &block)
            @filter_method = :prepend_before_action
            @filter_options = options
            @filter_block = block
          end
        end

        def prepend_view_path(path)
          (@view_paths ||= []).unshift(path)
        end

        def view_paths
          @view_paths || []
        end
      end
    end

    it "registers layout on the class once, outside the before_action" do
      ThemesOnRails::ActionController.apply_theme(controller_class, "theme_a")

      expect(controller_class.layout_args.first).to respond_to(:call)
      expect(controller_class.filter_method).to eq(:before_action)

      layout_calls = 0
      allow(controller_class).to receive(:layout) { layout_calls += 1 }
      controller_class.filter_block.call(controller_class.new)
      expect(layout_calls).to eq(0)
    end

    it "prepends the theme view path from the before_action" do
      ThemesOnRails::ActionController.apply_theme(controller_class, "theme_a")
      instance = controller_class.new
      controller_class.filter_block.call(instance)

      expect(instance.view_paths).to include("#{Rails.root}/app/themes/theme_a/views")
    end

    it "uses prepend_before_action when prepend: true" do
      ThemesOnRails::ActionController.apply_theme(controller_class, "theme_a", prepend: true)

      expect(controller_class.filter_method).to eq(:prepend_before_action)
    end
  end
end