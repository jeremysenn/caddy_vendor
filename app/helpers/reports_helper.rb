module ReportsHelper
  def reports_sort_link(column, title = nil)
    title ||= column.titleize
    direction = (column == reports_sort_column && reports_sort_direction == "asc") ? "desc" : "asc"
    icon = (reports_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == reports_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {reports_column: column, reports_direction: direction}
  end
end
