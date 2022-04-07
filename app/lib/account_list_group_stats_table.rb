class AccountListGroupStatsTable < AccountListStatsTable
  def initialize(data)
    @og_data = data
    @data = @og_data.map{|data| data[1]["data"]}.flatten
  end

  def table(type)
    rows = [
      name_header_row(type),
      dates_header_row(type),
      main_header_row,
      newsletter_row(type),
      blank_row
    ]
    rows += task_action_rows
    rows << blank_row
    rows += task_tags_rows
    rows << totals_row(rows, type)
    rows
  end

  private

  def name_header_row(type)
    cells = [{text: "", colspan: "3"}]

    number_of_time_periods.times do |i|
      color = i.even? ? :white : nil
      cells << {text: @og_data.keys[i], colspan: "2", class: cell_class(color)}
    end
    {type: "header", cells: cells}
  end
end