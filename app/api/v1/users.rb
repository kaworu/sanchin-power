# frozen_string_literal: true

require 'api/v1/base'

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
          on.failure :create do |messages|
            status :conflict
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
        last_seen = http_if_unmodified_since
        transaction = UserConcept::Transactions::Update.new
        transaction.with_step_args(
          find: [id: id],
          authorize: [current_user],
          match: [last_seen]
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
            status(last_seen ? :precondition_failed : :precondition_required)
          end
          on.failure :validate do |messages|
            status :bad_request
            json messages
          end
          on.failure :validate_login do |messages|
            status :bad_request
            json messages
          end
          on.failure :validate_password do |messages|
            status :bad_request
            json messages
          end
          on.failure :update do |messages|
            status :conflict
            json messages
          end
        end
      end

      # User destruction end-point.
      delete '/api/v1/users/:id' do |id|
        last_seen = http_if_unmodified_since
        transaction = UserConcept::Transactions::Destroy.new
        transaction.with_step_args(
          authorize: [current_user],
          match: [last_seen]
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
            status(last_seen ? :precondition_failed : :precondition_required)
          end
        end
      end
    end
  end
end
