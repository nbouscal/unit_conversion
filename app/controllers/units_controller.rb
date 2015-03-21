class UnitsController < ApplicationController

  # POST /units/convert
  # POST /units/convert.json
  def convert
    @converted = Unit.to_SI(params[:name], params[:input_value])

    render json: @converted
  end

end
