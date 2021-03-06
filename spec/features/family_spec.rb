describe 'Family' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:family){ create(:family) }
  let!(:other_family){ create(:family) }
  let!(:case){ create(:case, family: other_family) }
  before do
    login_as(admin)
  end
  feature 'List' do
    before do
      visit families_path
    end

    scenario 'name' do
      expect(page).to have_content(family.name)
    end

    scenario 'edit link' do
      expect(page).to have_link(nil, edit_family_path(family))
    end

    scenario 'delete link' do
      expect(page).to have_css("a[href='#{family_path(family)}'][data-method='delete']")
    end

    scenario 'show link' do
      expect(page).to have_link(nil, family_path(family))
    end

    scenario 'new link' do
      expect(page).to have_link('Add New Family', new_family_path)
    end
  end

  feature 'Create' do
    before do
      visit new_family_path
    end
    scenario 'valid' do
      fill_in 'Name', with: FFaker::Name.name
      fill_in 'Address', with: FFaker::Address.street_address
      fill_in 'Caregiver Information', with: FFaker::Lorem.paragraph
      click_button 'Save'
      expect(page).to have_content('Family has been successfully created')
    end

    xscenario 'invalid' do
      click_button 'Save'
      expect(page).to have_content("can't be blank")
    end
  end

  feature 'Edit' do
    let!(:name) { FFaker::Name.name }
    before do
      visit edit_family_path(family)
    end
    scenario 'valid' do
      fill_in 'Name', with: name
      click_button 'Save'
      expect(page).to have_content('Family has been successfully updated')
      expect(page).to have_content(name)
    end
    xscenario 'invalid'
  end

  feature 'Delete' do
    before do
      visit families_path
    end
    scenario 'success' do
      find("a[href='#{family_path(family)}'][data-method='delete']").click
      expect(page).to have_content('Family has been successfully deleted')
    end
    scenario 'unsuccess' do
      expect(page).not_to have_css("a[href='#{family_path(other_family)}'][data-method='delete']")
    end
  end

  feature 'Show' do
    before do
      visit family_path(family)
    end
    scenario 'success' do
      expect(page).to have_content(family.name)
    end
    scenario 'link to edit' do
      expect(page).to have_link(nil, href: edit_family_path(family, locale: I18n.locale))
    end
    scenario 'link to delete' do
      expect(page).to have_css("a[href='#{family_path(family, locale: I18n.locale)}'][data-method='delete']")
    end
    scenario 'disable delete' do
      visit family_path(other_family)
      expect(page).not_to have_css("a[href='#{family_path(other_family, locale: I18n.locale)}'][data-method='delete']")
    end
  end
end
