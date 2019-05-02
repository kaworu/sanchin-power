# frozen_string_literal: true

module Sanchin
  module APIv1
    # Sanchin user concept related end-points.
    class Users < Base
      # User creation end-point.
      post '/api/v1/users' do
        transaction = UserConcept::Transactions::Create.new
        transaction.with_step_args(
          authorize: [current_user]
        ).call(json_body) do |on|
          on.success do |user|
            status :created
            last_modified user.updated_at
            json user
          end
          on.failure :authorize do
            status :unauthorized
          end
          on.failure :validate do |messages|
            status :bad_request
            json messages
          end
        end
      end

      # User search end-point.
      get '/api/v1/users' do
        transaction = UserConcept::Transactions::Search.new
        transaction.with_step_args(
          authorize: [current_user]
        ).call do |on|
          on.success do |users|
            status :ok
            last_modified users.map(&:updated_at).max
            json users
          end
          on.failure :authorize do
            status :unauthorized
          end
        end
      end

      # User reading end-point.
      get '/api/v1/users/:id' do |id|
        transaction = UserConcept::Transactions::Find.new
        transaction.with_step_args(
          authorize: [current_user]
        ).call(id) do |on|
          on.success do |user|
            status :ok
            last_modified user.updated_at
            json user
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status :unauthorized
          end
        end
      end

      # User update end-point.
      patch '/api/v1/users/:id' do |id|
        transaction = UserConcept::Transactions::Update.new
        transaction.with_step_args(
          find: [id: id],
          authorize: [current_user],
          match: [http_if_unmodified_since]
        ).call(json_body) do |on|
          on.success do |user|
            status :ok
            last_modified user.updated_at
            json user
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status :unauthorized
          end
          on.failure :match do
            status :precondition_failed
          end
          on.failure :validate do |messages|
            status :bad_request
            json messages
          end
        end
      end

      # User destruction end-point.
      delete '/api/v1/users/:id' do |id|
        transaction = UserConcept::Transactions::Destroy.new
        transaction.with_step_args(
          authorize: [current_user],
          match: [http_if_unmodified_since]
        ).call(id) do |on|
          on.success do
            status :no_content
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status :unauthorized
          end
          on.failure :match do
            status :precondition_failed
          end
        end
      end
    end
  end
end
