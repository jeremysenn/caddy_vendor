module ApplicationHelper
  
  def transfers_sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == transfers_sort_column) ? "current #{transfers_sort_direction}" : nil
    direction = (column == transfers_sort_column && transfers_sort_direction == "asc") ? "desc" : "asc"
    link_to title, params.merge(:transfers_sort => column, :transfers_direction => direction, :page => nil), {:class => css_class}
  end
  
end
