module ApplicationHelper

  def js_render_to_div(dom_selector, partial_name, locals = {})
    rendered = render(partial: partial_name, locals: locals)
    escaped  = escape_javascript(rendered)
    raw %[$("#{dom_selector}").html('#{escaped}');]
  end

  def nav_link(text, path)
    active = if request.path == path then "active" end

    raw <<-HTML
      <li class="#{active}">
        <a href="#{h path}">#{h text}</a>
      </li>
    HTML
  end

end
