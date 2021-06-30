class AccountListStatsTable
  def initialize(data)
    @data = data
    @data = @data["data"] if @data.key?("data")
  end

  def table(type)
    rows = [
      dates_header_row(type),
      main_header_row,
      newsletter_row,
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
      text = "Week #{index + 1} <br> #{start_date}-#{end_date}"
    else
      text = DateTime.parse(attributes["start_date"]).strftime("%b&nbsp;%Y")
    end
    {text: text.html_safe, colspan: "2", class: (white ? "cell-white" : nil) }
  end

  def main_header_row
    cells = [{text: "Newsletter"}, {text: ""}, {text: "Points"}]
    number_of_time_periods.times do |i|
      white = i.even?
      cells << {text: "#", class: (white ? "cell-white" : nil)}
      cells << {text: "Points", class: (white ? "cell-white" : nil)}
    end
    {type: "header", cells: cells}
  end

  def newsletter_row
    cells = [
      {text: 'Last Prayer Letter (Put an "X" in week it was sent)'},
      {text: "Newsletter - Physical or Email"},
      {text: "25", class: "cell-data"}
    ]
    number_of_time_periods.times do |i|
      white = i.even?
      cells << {text: "", class: (white ? "cell-white" : nil)}
      cells << {text: "", class: (white ? "cell-white" : nil)}
    end
    {cells: cells}
  end

  def task_action_rows
    header_row = {
      type: "header", cells: [{text: "From MPDX Coaching Report"}, {text: "MPDX Task Action"}]
    }
    [header_row] +
      task_action_mappings.map do |mapping|
        cells = [{text: mapping[:name]}, {text: mapping[:actions]}, {text: mapping[:points], class: "cell-data"}]
        number_of_time_periods.times do |i|
          times = @data[i]["attributes"].dig(*mapping[:data_attribute].split(".")).to_i
          white = i.even?
          cells << {text: times, class: (white ? "cell-data cell-white" : "cell-data")}
          cells << {text: times * mapping[:points], class: (white ? "cell-data cell-white" : "cell-data")}
        end
        {cells: cells}
      end
  end

  def task_tags_rows
    header_row = {
      type: "header",
      cells: [
        {text: "For any activity, add the following bonus points [Using MPDX Task Tags]"},
        {text: "Where to find on MPDX Coaching Report"}
      ]
    }
    [header_row] +
      task_tags_mappings.map do |mapping|
        cells = [{text: mapping[:name]}, {text: mapping[:actions]}, {text: mapping[:points], class: "cell-data"}]
        number_of_time_periods.times do |i|
          times = @data[i]["attributes"].dig(*mapping[:data_attribute].split(".")).to_i
          white = i.even?
          cells << {text: times, class: (white ? "cell-data cell-white" : "cell-data")}
          cells << {text: times * mapping[:points], class: (white ? "cell-data cell-white" : "cell-data")}
        end
        {cells: cells}
      end
  end

  def totals_row(previous_rows, type)
    goal = type == :weekly ? 200 : 800
    cells = [{text: "Weekly effort goal"}, {text: ""}, {text: goal, class: "cell-data"}]
    number_of_time_periods.times do |i|
      col_number = 4 + (i * 2)
      sum = previous_rows.map { |r| r.dig(:cells, col_number, :text) }.select { |v| v.is_a? Numeric }.sum
      white = i.even?
      cells << {text: "", class: (white ? "cell-white" : nil)}
      color = if sum >= goal
        "cell-green"
      elsif white
        "cell-white"
      else
        ""
      end
      cells << {text: sum, class: "cell-data cell-data--bold #{color}"}
    end
    {cells: cells}
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
      {name: "Phone Calls: Outgoing & Received", actions: "Call", points: 1, data_attribute: "phone.completed"},
      {name: "Phone Calls: Talked to", actions: "Call", points: 2, data_attribute: "phone.completed"},
      {name: "Electronic Messages: Sent", actions: "Email, Text Message, Facebook Message", points: 1, data_attribute: "electronic.sent"}
    ]
  end

  def task_tags_mappings
    [
      {name: 'Ask for financial support ("bonus" points) ["ask-financial"]', actions: "Task Tags", points: 5, data_attribute: "tags.ask-financial"},
      {name: 'Ask for referrals ("bonus" points) ["ask-referrals"]', actions: "Task Tags", points: 5, data_attribute: "tags.ask-referrals"},
      {name: 'Ask to become an advocate ("bonus" points) ["ask-advocate"]', actions: "Task Tags", points: 10, data_attribute: "tags.ask-advocate"}
    ]
  end
end
