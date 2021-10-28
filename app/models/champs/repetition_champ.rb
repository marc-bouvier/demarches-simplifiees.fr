# == Schema Information
#
# Table name: champs
#
#  id                             :integer          not null, primary key
#  data                           :jsonb
#  fetch_external_data_exceptions :string           is an Array
#  private                        :boolean          default(FALSE), not null
#  rebased_at                     :datetime
#  row                            :integer
#  type                           :string
#  value                          :string
#  value_json                     :jsonb
#  created_at                     :datetime
#  updated_at                     :datetime
#  dossier_id                     :integer
#  etablissement_id               :integer
#  external_id                    :string
#  parent_id                      :bigint
#  type_de_champ_id               :integer
#
class Champs::RepetitionChamp < Champ
  accepts_nested_attributes_for :champs, allow_destroy: true

  def rows
    champs.group_by(&:row).values
  end

  def add_row
    transaction do
      row = (blank? ? -1 : champs.last.row) + 1
      type_de_champ.types_de_champ.each do |type_de_champ|
        self.champs << type_de_champ.champ.build(row: row)
      end
    end
  end

  def blank?
    champs.empty?
  end

  def search_terms
    # The user cannot enter any information here so it doesn’t make much sense to search
  end

  def for_tag
    ([libelle] + rows.map do |champs|
      champs.map do |champ|
        "#{champ.libelle} : #{champ}"
      end.join("\n")
    end).join("\n\n")
  end

  def rows_for_export
    rows.each.with_index(1).map do |champs, index|
      Champs::RepetitionChamp::Row.new(index: index, dossier_id: dossier_id.to_s, champs: champs)
    end
  end

  # We have to truncate the label here as spreadsheets have a (30 char) limit on length.
  def libelle_for_export
    str = "(#{stable_id}) #{libelle}"
    # /\*?[] are invalid Excel worksheet characters
    ActiveStorage::Filename.new(str.delete('[]*?')).sanitized
  end

  class Row < Hashie::Dash
    property :index
    property :dossier_id
    property :champs

    def read_attribute_for_serialization(attribute)
      self[attribute]
    end

    def spreadsheet_columns
      [
        ['Dossier ID', :dossier_id],
        ['Ligne', :index]
      ] + exported_champs
    end

    private

    def exported_champs
      champs.reject(&:exclude_from_export?).map do |champ|
        [champ.libelle, champ.for_export]
      end
    end
  end
end
