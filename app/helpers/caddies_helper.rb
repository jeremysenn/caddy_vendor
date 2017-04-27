module CaddiesHelper
  def caddies_sort_link(column, title = nil)
    title ||= column.titleize
    direction = (column == caddies_sort_column && caddies_sort_direction == "asc") ? "desc" : "asc"
    icon = (caddies_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == caddies_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {caddies_column: column, caddies_direction: direction}
  end
end
