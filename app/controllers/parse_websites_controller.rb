class ParseWebsitesController < ApplicationController

  before_action :set_imd_states, only: [:index]

  def index
  end

  def parse_imd_aws_data
    from_date = params["aws_data"]["from_date"]
    to_date = params["aws_data"]["to_date"]
    from_date = Date.parse(from_date).strftime("%d/%m/%Y")
    to_date = Date.parse(to_date).strftime("%d/%m/%Y")
    imd_state_code = params["aws_data"]["imd_state_code"]
    response = ImdAwsDatum.parse_imd_aws_data(from_date, to_date, imd_state_code)
    if response[:status]
      redirect_to "/imd_aws_data", notice: "Imd Aws Data added successfully"
    else
      redirect_to "/imd_aws_data", alert: "Imd Aws Data failed to save because of #{response[:error_messages]}"
    end
  end

end