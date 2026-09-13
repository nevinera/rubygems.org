# frozen_string_literal: true

class HistoricalOwnership < ApplicationRecord
  belongs_to :rubygem
  belongs_to :user

  # The numeric enum values here are intentionally defined by lib/access.rb in ascending order of privilege.
  enum :role, { owner: Access::OWNER, maintainer: Access::MAINTAINER }, validate: true
  ROLE_HIERARCHY = roles.sort_by { |_role, flag| flag }.map(&:first).freeze

  scope :current, -> { where(removed_at: nil) }
  scope :alumni, -> { where.not(removed_at: nil) }
  scope :not_private, -> { where(private_at: nil) }

  def self.roles_below(role)
    ROLE_HIERARCHY.first(ROLE_HIERARCHY.index(role.to_s))
  end

  def private?
    private_at.present?
  end

  def make_private!
    update!(private_at: Time.current) unless private?
  end

  def make_public!
    update!(private_at: nil) if private?
  end
end
