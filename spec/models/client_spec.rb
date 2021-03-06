describe Client, 'associations' do

  it { is_expected.to belong_to(:referral_source) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:received_by) }
  it { is_expected.to belong_to(:followed_up_by) }
  it { is_expected.to belong_to(:birth_province) }

  it { is_expected.to have_many(:cases) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:case_notes) }
  it { is_expected.to have_many(:assessments) }

  it { is_expected.to have_and_belong_to_many(:agencies) }
  it { is_expected.to have_and_belong_to_many(:quantitative_cases) }

end

describe Client, 'methods' do
  let!(:client){ create(:client) }
  let!(:assessment){ create(:assessment, created_at: Date.today - 6.month, client: client) }
  let!(:other_client) { create(:client) }
  context 'name' do
    let!(:name){ "#{client.first_name} #{client.last_name}" }
    it { expect(client.name).to eq(name) }
  end

  context 'next assessment date' do
    let!(:latest_assessment){ create(:assessment, client: client) }
    it 'should be latest assessment + 6 months' do
      expect(client.next_assessment_date.to_date).to eq((latest_assessment.created_at + 6.month).to_date)
    end
    it 'should be today' do
      expect(other_client.next_assessment_date.start).to eq(Date.today.start)
    end
  end

  context 'can create assessment' do
    let!(:other_assessment) { create(:assessment, client: other_client) }
    it { expect(client.can_create_assessment?).to be_truthy }
    it { expect(other_client.can_create_assessment?).to be_falsey }
  end

  context 'can create case note' do
    it { expect(client.can_create_case_note?).to be_truthy }
    it { expect(other_client.can_create_case_note?).to be_falsey }
  end

end

describe Client, 'scopes' do
  let!(:user){ create(:user) }
  let!(:follower){ create(:user)}
  let!(:referral_source) { create(:referral_source)}
  let!(:province){ create(:province) }
  let!(:client){ create(:client,
    first_name: 'Example First Name',
    last_name: 'Example Last Name',
    school_name: 'Example school',
    school_grade: 'Example grade',
    referral_phone: '012678779',
    relevant_referral_information: 'Example Info',
    referral_source: referral_source,
    received_by: user,
    state: 'accepted',
    gender: 'female',
    followed_up_by: follower,
    birth_province: province,
    province: province,
    user: user
  )}
  let!(:other_client){ create(:client, state: 'rejected') }
  context 'first name like' do
    let!(:clients){ Client.first_name_like(client.first_name.downcase) }
    it 'should include record have first name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have first name like' do
      expect(clients).not_to include(other_client)
    end
  end

  # todo : remove when stable
  xcontext 'last name like' do
    let!(:clients){ Client.last_name_like(client.last_name.downcase) }
    it 'should include record have last name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have last name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'current address like' do
    let!(:clients){ Client.current_address_like(client.current_address.downcase[0, 10]) }
    it 'should include record have address like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have address like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'school name like' do
    let!(:clients){ Client.school_name_like(client.school_name.downcase) }
    it 'should include record have school name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have school name like' do
      expect(clients).not_to include(other_client)
    end
  end

  # To do: remove when stable (This was changed from string filter to integer range filter)
  # context 'school grade like' do
  #   let!(:clients){ Client.school_grade_like(client.school_grade.downcase) }
  #   it 'should include record have school grade like' do
  #     expect(clients).to include(client)
  #   end
  #   it 'should not include record not have school grade like' do
  #     expect(clients).not_to include(other_client)
  #   end
  # end

  context 'referral phone like' do
    let!(:clients){ Client.referral_phone_like(client.referral_phone.downcase) }
    it 'should include record have referral phone like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have referral phone like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'info like' do
    let!(:clients){ Client.info_like(client.relevant_referral_information.downcase[0, 10]) }
    it 'should include record have info like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have info like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'is received by' do
    let!(:received_by){ [user.name, user.id] }
    let!(:is_received_by){ Client.is_received_by }
    it 'should return username and id' do
      expect(is_received_by).to include(received_by)
    end
  end

  context 'referral source is' do
    let!(:referral_sources){ [referral_source.name, referral_source.id] }
    let!(:referral_source_is){ Client.referral_source_is }
    it 'should return referral source name and id' do
      expect(referral_source_is).to include(referral_sources)
    end
  end

  context 'is follow up by' do
    let!(:follow_up){ [follower.name, follower.id] }
    let!(:is_followed_up_by){ Client.is_followed_up_by }
    it 'should return follower name and id' do
      expect(is_followed_up_by).to include(follow_up)
    end
  end

  context 'birth province is' do
    let!(:birth_province){ [province.name, province.id] }
    let!(:birth_province_is){ Client.birth_province_is }
    xit 'should return birth province name and id' do
      expect(birth_province_is).to include(birth_province)
    end
  end

  context 'province is' do
    let!(:provinces){ [province.name, province.id] }
    let!(:province_is){ Client.province_is }
    it 'should return province name and id' do
      expect(province_is).to include(provinces)
    end
  end

  context 'case worker is' do
    let!(:case_worker){ [user.name, user.id] }
    let!(:case_worker_is){ Client.case_worker_is }
    xit 'should return case worker name and id' do
      expect(case_worker_is).to include(case_worker)
    end
  end

  context 'state' do
    it 'accepted' do
      expect(Client.accepted).to include(client)
    end
    it 'rejected' do
      expect(Client.rejected).to include(other_client)
    end
  end

  context 'gender' do
    it 'male' do
      expect(Client.male).to include(other_client)
    end
    it 'female' do
      expect(Client.female).to include(client)
    end
  end

  context 'start with code' do
    let(:kc_client) { create(:client, status: 'Active KC', state: 'accepted') }
    let(:fc_client) { create(:client, status: 'Active FC', state: 'accepted') }
    let!(:kc) { create(:case, client: kc_client, case_type: 'KC') }
    let!(:fc) { create(:case, client: fc_client, case_type: 'FC') }

    it 'should return active kc case with code start from 2' do
      expect(Client.start_with_code(2).count).to eq 1
      expect(Client.start_with_code(2).first.code).to eq '2000'
    end

    it 'should return active fc case with code start from 1' do
      expect(Client.start_with_code(1).count).to eq 1
      expect(Client.start_with_code(1).first.code).to eq '1000'
    end
  end
end
