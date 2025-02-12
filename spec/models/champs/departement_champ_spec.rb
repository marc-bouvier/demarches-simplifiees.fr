describe Champs::DepartementChamp, type: :model do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  let(:champ) { described_class.new }

  describe 'value', vcr: { cassette_name: 'api_geo_departements' } do
    it 'with code having 2 chars' do
      champ.value = '01'
      expect(champ.external_id).to eq('01')
      expect(champ.code).to eq('01')
      expect(champ.name).to eq('Ain')
      expect(champ.value).to eq('Ain')
      expect(champ.selected).to eq('01')
      expect(champ.to_s).to eq('01 – Ain')
      expect(champ.for_api_v2).to eq('01 - Ain')
    end

    it 'with code having 3 chars' do
      champ.value = '971'
      expect(champ.external_id).to eq('971')
      expect(champ.code).to eq('971')
      expect(champ.name).to eq('Guadeloupe')
      expect(champ.value).to eq('Guadeloupe')
      expect(champ.selected).to eq('971')
      expect(champ.to_s).to eq('971 – Guadeloupe')
    end

    it 'with alphanumeric code' do
      champ.value = '2B'
      expect(champ.external_id).to eq('2B')
      expect(champ.code).to eq('2B')
      expect(champ.name).to eq('Haute-Corse')
      expect(champ.value).to eq('Haute-Corse')
      expect(champ.selected).to eq('2B')
      expect(champ.to_s).to eq('2B – Haute-Corse')
    end

    it 'with nil' do
      champ.write_attribute(:value, 'Ain')
      champ.write_attribute(:external_id, '01')
      champ.value = nil
      expect(champ.external_id).to be_nil
      expect(champ.code).to be_nil
      expect(champ.name).to be_nil
      expect(champ.value).to be_nil
      expect(champ.selected).to be_nil
      expect(champ.to_s).to eq('')
    end

    it 'with blank' do
      champ.write_attribute(:value, 'Ain')
      champ.write_attribute(:external_id, '01')
      champ.value = ''
      expect(champ.external_id).to be_nil
      expect(champ.value).to be_nil
      expect(champ.selected).to be_nil
      expect(champ.to_s).to eq('')
    end

    it 'with initial nil' do
      champ.write_attribute(:value, nil)
      expect(champ.external_id).to be_nil
      expect(champ.code).to be_nil
      expect(champ.name).to be_nil
      expect(champ.value).to be_nil
      expect(champ.selected).to be_nil
      expect(champ.to_s).to eq('')
    end

    it 'with initial code and name' do
      champ.write_attribute(:value, '01 - Ain')
      expect(champ.external_id).to be_nil
      expect(champ.code).to eq('01')
      expect(champ.name).to eq('Ain')
      expect(champ.value).to eq('01 - Ain')
      expect(champ.selected).to eq('01')
      expect(champ.to_s).to eq('01 – Ain')
    end

    it 'with initial code and alphanumeric name' do
      champ.write_attribute(:value, '2B - Haute-Corse')
      expect(champ.external_id).to be_nil
      expect(champ.code).to eq('2B')
      expect(champ.name).to eq('Haute-Corse')
      expect(champ.value).to eq('2B - Haute-Corse')
      expect(champ.selected).to eq('2B')
      expect(champ.to_s).to eq('2B – Haute-Corse')
    end
  end
end
