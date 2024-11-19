module Api
  module V1
    class CustomersController < ApplicationController
      before_action :set_customer, only: [ :show, :update, :destroy ]

      def index
        @customers = if params[:include_deleted]
                      Customer.with_deleted
        else
                      Customer.without_deleted
        end

        render json: @customers
      end

      def show
        render json: @customer
      end

      def create
        @customer = Customer.new(customer_params)

        if @customer.save
          render json: @customer, status: :created
        else
          render json: { errors: @customer.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @customer.update(customer_params)
          render json: @customer
        else
          render json: { errors: @customer.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @customer.destroy
        head :no_content
      end

      private

      def set_customer
        @customer = if params[:include_deleted]
                     Customer.with_deleted.find(params[:id])
        else
                     Customer.find(params[:id])
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Customer not found" }, status: :not_found
      end

      def customer_params
        params.require(:customer).permit(
          :name,
          :email,
          :document_number,
          :phone,
          :address,
          :city,
          :state,
          :zip_code,
          :birthdate,
          :income
        )
      end
    end
  end
end
