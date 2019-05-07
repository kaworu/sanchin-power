# frozen_string_literal: true

require 'api/v1/base'

module Sanchin
  module APIv1
    # Sanchin user concept related end-points.
    class Users < Base
      # User creation end-point.
      post '/api/v1/users', authenticated: true do
        transaction = UserConcept::Transactions::Create.new
        transaction.with_step_args(
          authorize: [@current_user]
        ).call(json_body) do |on|
          on.success do |user|
            status :created
            etag user.version, :weak
            json user
          end
          on.failure :authorize do
            status(@current_user ? :forbidden : :unauthorized)
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
      get '/api/v1/users', authenticated: true do
        transaction = UserConcept::Transactions::Search.new
        transaction.with_step_args(
          authorize: [@current_user]
        ).call do |on|
          on.success do |users|
            status :ok
            json users
          end
          on.failure :authorize do
            status(@current_user ? :forbidden : :unauthorized)
          end
        end
      end

      # User reading end-point.
      get '/api/v1/users/:id', authenticated: true do |id|
        transaction = UserConcept::Transactions::Find.new
        transaction.with_step_args(
          authorize: [@current_user]
        ).call(id) do |on|
          on.success do |user|
            etag user.version, :weak
            status :ok
            json user
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status(@current_user ? :forbidden : :unauthorized)
          end
        end
      end

      # User update end-point.
      patch '/api/v1/users/:id', authenticated: true do |id|
        version = if_match_version
        transaction = UserConcept::Transactions::Update.new
        transaction.with_step_args(
          find: [id: id],
          authorize: [@current_user],
          match: [version]
        ).call(json_body) do |on|
          on.success do |user|
            status :ok
            json user
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status(@current_user ? :forbidden : :unauthorized)
          end
          on.failure :match do
            status(version ? :precondition_failed : :precondition_required)
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
      delete '/api/v1/users/:id', authenticated: true do |id|
        version = if_match_version
        transaction = UserConcept::Transactions::Destroy.new
        transaction.with_step_args(
          authorize: [@current_user],
          match: [version]
        ).call(id) do |on|
          on.success do
            status :no_content
          end
          on.failure :find do
            status :not_found
          end
          on.failure :authorize do
            status(@current_user ? :forbidden : :unauthorized)
          end
          on.failure :match do
            status(version ? :precondition_failed : :precondition_required)
          end
        end
      end
    end
  end
end
