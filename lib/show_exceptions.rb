require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)
  rescue Exception => e
    render_exception(e)
  end

  private

  def render_exception(e)
    res = Rack::Response.new

    dir_path = File.dirname(__FILE__)
    template_path = File.join(dir_path, "templates", "rescue.html.erb")
    template_str = File.read(template_path)
    template_body = ERB.new(template_str).result(binding)

    res.status = 500
    res['Content-Type'] = 'text/html'
    res.write(template_body)
    res.finish
  end

  def find_src_line_num(e)
    find_top_stack_trace(e)[1].to_i
  end

  def find_src_file(e)
    find_top_stack_trace(e)[0]
  end

  def find_top_stack_trace(e)
    e.backtrace.first.split(':')
  end

  def extract_formatted_source(e)
    source_line_num = find_src_line_num(e)
    file = find_src_file(e) 
    source_lines = extract_source(file)
    format_source(source_lines, source_line_num)
  end

  def extract_source(file)
    source_file = File.open(file, 'r')
    source_file.readlines
  end

  def format_source(source_lines, source_line_num)
    start_num = [0, source_line_num - 3].max
    lines = source_lines[start_num..(start_num + 5)]
    p lines
    Hash[[*(start_num + 1)..(start_num + lines.count)].zip(lines)]     
  end
end
