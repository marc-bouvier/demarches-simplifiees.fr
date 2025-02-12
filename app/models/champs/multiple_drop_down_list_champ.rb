# == Schema Information
#
# Table name: champs
#
#  id                             :integer          not null, primary key
#  data                           :jsonb
#  fetch_external_data_exceptions :string           is an Array
#  prefilled                      :boolean          default(FALSE)
#  private                        :boolean          default(FALSE), not null
#  rebased_at                     :datetime
#  type                           :string
#  value                          :string
#  value_json                     :jsonb
#  created_at                     :datetime
#  updated_at                     :datetime
#  dossier_id                     :integer
#  etablissement_id               :integer
#  external_id                    :string
#  parent_id                      :bigint
#  row_id                         :string
#  type_de_champ_id               :integer
#
class Champs::MultipleDropDownListChamp < Champ
  before_save :format_before_save

  def options?
    drop_down_list_options?
  end

  def options
    drop_down_list_options
  end

  def disabled_options
    drop_down_list_disabled_options
  end

  def enabled_non_empty_options
    drop_down_list_enabled_non_empty_options
  end

  THRESHOLD_NB_OPTIONS_AS_CHECKBOX = 5

  def search_terms
    selected_options
  end

  def selected_options
    value.blank? ? [] : JSON.parse(value)
  end

  def to_s
    selected_options.join(', ')
  end

  def for_tag
    selected_options.join(', ')
  end

  def for_export
    value.present? ? selected_options.join(', ') : nil
  end

  def render_as_checkboxes?
    enabled_non_empty_options.size <= THRESHOLD_NB_OPTIONS_AS_CHECKBOX
  end

  def blank?
    selected_options.blank?
  end

  def in?(options)
    (selected_options - options).size != selected_options.size
  end

  def remove_option(options)
    update_column(:value, (selected_options - options).to_json)
  end

  private

  def format_before_save
    if value.present?
      json = JSON.parse(value)
      if json == ['']
        self.value = nil
      else
        json = json - ['']
        self.value = json.to_s
      end
    end
  end
end
