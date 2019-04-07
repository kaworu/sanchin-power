# frozen_string_literal: true

require 'trailblazer'
require_relative '../schemas/create'
require_relative '../presenter'

module UserConcept
  module Operation
    # User Creation Operation.
    #
    # Dependencies:
    #   user_repo: the User repositry
    #   payload:   the User data
    #
    # Results:
    #   changeset:   the user creation changeset
    #   validation:  the payload validations
    #   created:     the created user instance (on success)
    #   presentable: the created user presentation (on success)
    class Create < Trailblazer::Operation
      pass :changeset
      step :validation
      pass :persist
      pass :present

      protected

      def changeset(options, user_repo:, payload:, **)
        options[:changeset] = user_repo.create(payload)
      end

      def validation(options, changeset:, **)
        options[:validation] = Schema::Create.call(changeset.to_h)
        options[:validation].success?
      end

      def persist(options, changeset:, **)
        options[:created] = changeset.commit
      end

      def present(options, created:, **)
        options[:presentable] = Presenter.new(created)
      end
    end
  end
end
