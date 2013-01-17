class TransactionsController < ApplicationController

  include TransactionableController

  # GET /transactions
  # GET /transactions.json
  def index
    load_upcoming_transactions
    load_cleared_transactions
    @posted_transactions = Transaction.posted.paid_desc.to_a

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = Transaction.new
    @transaction.recurrence = Recurrence.new

    if params[:transaction_id].present?
      source = Transaction.find(params[:transaction_id])
      @transaction.amount      = source.amount
      @transaction.payee       = source.payee
      @transaction.description = source.description
      @transaction.paid_at     = source.paid_at
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render partial: "modal_form", locals: { transaction: @transaction }
        end
      end
      format.json { render json: @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])

    if request.xhr?
      render partial: "modal_form", locals: { transaction: @transaction }
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to transactions_path, notice: 'Transaction was successfully created.' }
        format.json { render json: @transaction, status: :created, location: @transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end

      format.js { load_dynamic_transactions }
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(transaction_params)
        format.html { redirect_to transactions_path, notice: 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end

      format.js { load_dynamic_transactions }
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
      format.js { load_dynamic_transactions }
    end
  end

  private

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def transaction_params
    extras = { recurrence_attributes: [ :frequency, :starts_at, :ends_at ] }
    params.require(:transaction).permit(:amount, :description, :paid_at, :payee, :transaction_type, :debit, :credit, extras)
  end

end
