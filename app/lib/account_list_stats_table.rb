class AccountListStatsTable
  def initialize(data)
    @data = data
    @data = @data["data"] if @data.key?("data")
  end

  def table(type)
    rows = [
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

  def dates_header_row(type)
    cells = [{text: "", colspan: "3"}]

    number_of_time_periods.times do |i|
      cells << date_header_cell(i, type, i.even?)
    end
    {type: "header", cells: cells}
  end

  def date_header_cell(index, type, white)
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

  def main_header_row
    cells = [{text: "Newsletter"}, {text: ""}, {text: "Points"}]
    number_of_time_periods.times do |i|
      color = i.even? ? :white : nil
      cells << {text: "#", class: cell_class(color)}
      cells << {text: "Points", class: cell_class(color)}
    end
    {type: "header", cells: cells}
  end

  def newsletter_row(type)
    cells = [
      {text: 'Prayer Letter Sent'},
      {text: "Newsletter - Physical or Email"},
      {text: "25", class: data_class}
    ]
    periods_to_score = tally_newsletters_for_periods(type)
    number_of_time_periods.times do |i|
      sent_letter = periods_to_score[i]
      color = i.even? ? :white : nil
      cells << {text: sent_letter ? "X" : "", class: data_class(color)}
      cells << {text: sent_letter ? 25 : "", class: data_class(color, true)}
    end
    {cells: cells}
  end

  def tally_newsletters_for_periods(type)
    tallies = number_of_time_periods.times.map do |i|
      @data[i]["attributes"]["correspondence"]["newsletters"].to_i.positive?
    end
    return tallies unless type == :weekly

    tallies.map.with_index do |value, i|
      future_tallies = tallies[(i + 1)..]
      value && !future_tallies.any?
    end
  end

  def task_action_rows
    header_row = {
      type: "header", cells: [{text: "From MPDX Coaching Report"}, {text: "MPDX Task Action"}]
    }
    [header_row] + row_for_mapping(task_action_mappings)
  end

  def task_tags_rows
    header_row = {
      type: "header",
      cells: [
        {text: "For any activity, add the following bonus points [Using MPDX Task Tags]"},
        {text: "Where to find on MPDX Coaching Report"}
      ]
    }
    [header_row] + row_for_mapping(task_tags_mappings)
  end

  def row_for_mapping(mapping)
    mapping.map do |mapping|
      cells = [{text: mapping[:name]}, {text: mapping[:actions]}, {text: mapping[:points], class: data_class}]
      number_of_time_periods.times do |i|
        times = 0
        mapping[:data_attribute].split("+").each do |map|
          times += @data[i]["attributes"].dig(*map.split(".")).to_i
        end
        color = i.even? ? :white : nil
        cells << {text: times, class: data_class(color)}
        cells << {text: times * mapping[:points], class: data_class(color, true)}
      end
      {cells: cells}
    end
  end

  def totals_row(previous_rows, type)
    goal = goal(type)
    cells = [
      {text: "Points Total"},
      {text: ""},
      {text: goal, class: data_class}
    ]
    number_of_time_periods.times do |i|
      col_number = 4 + (i * 2)
      sum = previous_rows.map { |r| r.dig(:cells, col_number, :text) }.select { |v| v.is_a? Numeric }.sum
      color = i.even? ? :white : nil
      cells << {text: "", class: cell_class(color)}
      color = :green if sum >= goal
      cells << {text: sum, class: data_class(color, true)}
    end
    {cells: cells}
  end

  def cell_class(color = :gray, bold = false)
    [
      bold ? "cell-data--bold" : nil,
      color != :gray ? "cell-#{color}" : nil
    ].compact.join(" ")
  end

  def data_class(color = :gray, bold = false)
    "cell-data #{cell_class(color, bold)}"
  end

  def goal(type)
    case type
    when :weekly
      200
    when :monthly
      800
    else
      0
    end
  end

  def blank_row
    {cells: [{text: "&nbsp;".html_safe, colspan: 3 + (number_of_time_periods * 2)}]}
  end

  def number_of_time_periods
    @data.count
  end

  def task_action_mappings
    [
      {name: "Contacts: Referrals Gained", actions: "N/A", points: 3, data_attribute: "contacts.referrals"},
      {name: "Appointments: Completed", actions: "Appointment", points: 5, data_attribute: "appointments.completed"},
      {name: "Correspondence: Pre call", actions: "Pre Call Letter", points: 2, data_attribute: "correspondence.precall"},
      {name: "Correspondence: Support", actions: "Support Letter", points: 2, data_attribute: "correspondence.support_letters"},
      {name: "Correspondence: Thank You", actions: "Thank", points: 1, data_attribute: "correspondence.thank_yous"},
      {name: "Correspondence: Reminder", actions: "Reminder Letter", points: 3, data_attribute: "correspondence.reminders"},
      {name: "Phone Calls: Outgoing & Received", actions: "Call", points: 1, data_attribute: "phone.attempted+phone.completed+phone.received"},
      {name: "Phone Calls: Talked to", actions: "Call", points: 2, data_attribute: "phone.completed"},
      {name: "Electronic Messages: Sent", actions: "Email, Text Message, Facebook Message", points: 1, data_attribute: "electronic.sent"}
    ]
  end

  def task_tags_mappings
    [
      {name: 'Ask for financial support ("bonus" points) ["ask-financial"]', actions: "Task Tags", points: 5, data_attribute: "tags.ask-financial"},
      {name: 'Ask for referrals ("bonus" points) ["ask-referrals"]', actions: "Task Tags", points: 5, data_attribute: "tags.ask-referrals"},
      {name: 'Ask to become an advocate ("bonus" points) ["ask-advocate"]', actions: "Task Tags", points: 10, data_attribute: "tags.ask-advocate"},
      {name: 'Circle Meeting ("bonus" points) ["circle-meeting"]', actions: "Task Tags", points: 5, data_attribute: "tags.circle-meeting"}
    ]
  end
end
