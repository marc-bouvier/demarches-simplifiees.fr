# == Schema Information
#
# Table name: deleted_dossiers
#
#  id                    :bigint           not null, primary key
#  deleted_at            :datetime
#  reason                :string
#  state                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  dossier_id            :bigint
#  groupe_instructeur_id :bigint
#  procedure_id          :bigint
#  revision_id           :bigint
#  user_id               :bigint
#
class DeletedDossier < ApplicationRecord
  belongs_to :procedure, -> { with_discarded }, inverse_of: :deleted_dossiers, optional: false
  belongs_to :groupe_instructeur, inverse_of: :deleted_dossiers, optional: true

  scope :order_by_updated_at, -> (order = :desc) { order(created_at: order) }
  scope :deleted_since,       -> (since) { where('deleted_dossiers.deleted_at >= ?', since) }

  enum reason: {
    user_request:      'user_request',
    manager_request:   'manager_request',
    user_removed:      'user_removed',
    procedure_removed: 'procedure_removed',
    expired:           'expired',
    instructeur_request: 'instructeur_request'
  }

  def self.create_from_dossier(dossier, reason)
    return if !dossier.log_operations?

    # We have some bad data because of partially deleted dossiers in the past.
    # For now use find_or_create_by! to avoid errors.
    create_with(
      reason: reasons.fetch(reason),
      groupe_instructeur_id: dossier.groupe_instructeur_id,
      revision_id: dossier.revision_id,
      user_id: dossier.user_id,
      procedure: dossier.procedure,
      state: dossier.state,
      deleted_at: Time.zone.now
    ).create_or_find_by!(dossier_id: dossier.id)
  end

  def procedure_removed?
    reason == self.class.reasons.fetch(:procedure_removed)
  end

  def user_locale
    User.find_by(id: user_id)&.locale || I18n.default_locale
  end
end
