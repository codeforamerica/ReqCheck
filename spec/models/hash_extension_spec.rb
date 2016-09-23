


RSpec.describe Hash do
  describe '#find_all_values_for' do
    let(:xml_string) { TestAntigen::ANTIGENSTRING } 
    let(:xml_hash) { Hash.from_xml(xml_string) } 
    
    it 'recursively pulls all data from a nested hash' do
      expect(xml_hash.find_all_values_for('cvx', numeric=true)).to eq([10, 110, 120, 130, 132, 146, 2, 89])
    end
  end
end