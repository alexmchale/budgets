class RecurrencesController < ApplicationController

  include TransactionableController

  # GET /recurrences
  # GET /recurrences.json
  def index
    @recurrences = Recurrence.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recurrences }
    end
  end

  # GET /recurrences/1
  # GET /recurrences/1.json
  def show
    @recurrence = Recurrence.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recurrence }
    end
  end

  # GET /recurrences/new
  # GET /recurrences/new.json
  def new
    @recurrence = Recurrence.new
    @recurrence.frequency = Recurrence.order("created_at DESC").first.try(:frequency)

    respond_to do |format|
      format.html { render partial: "modal_form", locals: { recurrence: @recurrence } if request.xhr? }
      format.json { render json: @recurrence }
    end
  end

  # GET /recurrences/1/edit
  def edit
    @recurrence = Recurrence.find(params[:id])
  end

  # POST /recurrences
  # POST /recurrences.json
  def create
    @recurrence = Recurrence.new(recurrence_params)

    respond_to do |format|
      if @recurrence.save
        format.html { redirect_to @recurrence, notice: 'Recurrence was successfully created.' }
        format.json { render json: @recurrence, status: :created, location: @recurrence }
      else
        format.html { render action: "new" }
        format.json { render json: @recurrence.errors, status: :unprocessable_entity }
      end

      format.js { load_dynamic_transactions }
    end
  end

  # PUT /recurrences/1
  # PUT /recurrences/1.json
  def update
    @recurrence = Recurrence.find(params[:id])

    respond_to do |format|
      if @recurrence.update_attributes(params[:recurrence])
        format.html { redirect_to @recurrence, notice: 'Recurrence was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recurrence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recurrences/1
  # DELETE /recurrences/1.json
  def destroy
    @recurrence = Recurrence.find(params[:id])
    @recurrence.destroy

    respond_to do |format|
      format.html { redirect_to recurrences_url }
      format.json { head :no_content }
    end
  end

  private

  def recurrence_params
    params.require(:recurrence).permit(:frequency, :starts_at, :ends_at, :amount, :debit, :credit, :payee, :description, :transaction_type)
  end

end
