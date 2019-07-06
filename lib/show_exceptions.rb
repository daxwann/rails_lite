require 'erb'

class ShowExceptions
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    render_exception(e)
  end

  private

  def render_exception(e)
    dir_path = File.dirname(__FILE__)
    template_path = File.join(dir_path, "template", "rescue.html.erb")
    template_str = File.read(template_path)
    template_body = ERB.new(template_str).result(binding)

    ['500', {'Content-Type' => 'text/html'}, template_body]
  end

  def show_src_line_num(e)
    find_top_stack_trace(e)[1].to_i
  end

  def show_src_filename(e)
    find_top_stack_trace(e)[0]
  end

  def find_top_stack_trace(e)
    e.backtrace.first.split(':')
  end
end
