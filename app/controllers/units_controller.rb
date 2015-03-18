class UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :update, :destroy]

  # GET /units
  # GET /units.json
  def index
    @units = Unit.all

    render json: @units
  end

  # GET /units/1
  # GET /units/1.json
  def show
    render json: @unit
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      render json: @unit, status: :created, location: @unit
    else
      render json: @unit.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    @unit = Unit.find(params[:id])

    if @unit.update(unit_params)
      head :no_content
    else
      render json: @unit.errors, status: :unprocessable_entity
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy

    head :no_content
  end

  private

    def set_unit
      @unit = Unit.find(params[:id])
    end

    def unit_params
      params.require(:unit).permit(:unit_name)
    end
end
