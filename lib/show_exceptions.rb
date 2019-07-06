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
end
