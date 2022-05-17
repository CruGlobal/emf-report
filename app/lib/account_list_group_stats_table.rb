class AccountListGroupStatsTable < AccountListStatsTable
  def initialize(data)
    @og_data = data
    @data = @og_data.map{|data| data[1]["data"]}.flatten
  end

  def table(type, goal = nil)
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
    rows += group_totals_row(rows, type, goal)
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

  def group_totals_row(previous_rows, type, goal)
    goal ||= goal(type)
    group_sum = 0
    cells = [
      {text: "Group Monthly Points Goal"},
      {text: ""},
      {text: goal, class: data_class}
    ]
    number_of_time_periods.times do |i|
      col_number = 4 + (i * 2)
      sum = previous_rows.map { |r| r.dig(:cells, col_number, :text) }.select { |v| v.is_a? Numeric }.sum
      group_sum += sum
      color = i.even? ? :white : nil
      cells << {text: "", class: cell_class(color)}
      cells << {text: sum, class: data_class(color, true)}
    end
    color = :green if group_sum >= goal
    group_summary_cells = [
      {text: "Group Total"},
      {text: ""},
      {text: group_sum, class: data_class(color, true)}
    ]
    [{cells: cells}] + [{cells: group_summary_cells}]
  end
end