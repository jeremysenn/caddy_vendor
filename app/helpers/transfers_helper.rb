module TransfersHelper
  def transfers_sort_link(column, title = nil)
    title ||= column.titleize
    direction = (column == transfers_sort_column && transfers_sort_direction == "asc") ? "desc" : "asc"
    icon = (transfers_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == transfers_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {transfers_column: column, transfers_direction: direction}
  end
end
