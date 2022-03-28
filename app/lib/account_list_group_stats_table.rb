class AccountListGroupStatsTable < AccountListStatsTable
  def initialize(data)
    @og_data = data
    @data = @og_data.map{|data| data[1]["data"]}.flatten
  end

  def table(type)
    rows = [
      name_header_row(type),
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
      cells << name_header_cell(i, type, i.even?)
    end
    {type: "header", cells: cells}
  end

  def name_header_cell(index, type, white)
    attributes = @data[index]["attributes"]
    text = nil
    if type == :weekly
      start_date = DateTime.parse(attributes["start_date"]).strftime("%b&nbsp;%d")
      end_date = DateTime.parse(attributes["end_date"]).strftime("%b&nbsp;%d")
      text = "#{start_date}-#{end_date}"
    else
      text = DateTime.parse(attributes["start_date"]).strftime("%b&nbsp;%Y")
    end
    color = white ? :white : nil
    {text: text.html_safe, colspan: "2", class: cell_class(color)}
  end
end