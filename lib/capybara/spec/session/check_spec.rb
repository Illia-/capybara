# frozen_string_literal: true
Capybara::SpecHelper.spec "#check" do
  before do
    @session.visit('/form')
  end

  describe "'checked' attribute" do
    it "should be true if checked" do
      @session.check("Terms of Use")
      expect(@session.find(:xpath, "//input[@id='form_terms_of_use']")['checked']).to be_truthy
    end

    it "should be false if unchecked" do
      expect(@session.find(:xpath, "//input[@id='form_terms_of_use']")['checked']).to be_falsey
    end
  end

  it "should trigger associated events", :requires => [:js] do
    @session.visit('/with_js')
    @session.check('checkbox_with_event')
    expect(@session).to have_css('#checkbox_event_triggered');
  end

  describe "checking" do
    it "should not change an already checked checkbox" do
      expect(@session.find(:xpath, "//input[@id='form_pets_dog']")['checked']).to be_truthy
      @session.check('form_pets_dog')
      expect(@session.find(:xpath, "//input[@id='form_pets_dog']")['checked']).to be_truthy
    end

    it "should check an unchecked checkbox" do
      expect(@session.find(:xpath, "//input[@id='form_pets_cat']")['checked']).to be_falsey
      @session.check('form_pets_cat')
      expect(@session.find(:xpath, "//input[@id='form_pets_cat']")['checked']).to be_truthy
    end
  end

  describe "unchecking" do
    it "should not change an already unchecked checkbox" do
      expect(@session.find(:xpath, "//input[@id='form_pets_cat']")['checked']).to be_falsey
      @session.uncheck('form_pets_cat')
      expect(@session.find(:xpath, "//input[@id='form_pets_cat']")['checked']).to be_falsey
    end

    it "should uncheck a checked checkbox" do
      expect(@session.find(:xpath, "//input[@id='form_pets_dog']")['checked']).to be_truthy
      @session.uncheck('form_pets_dog')
      expect(@session.find(:xpath, "//input[@id='form_pets_dog']")['checked']).to be_falsey
    end
  end

  it "should check a checkbox by id" do
    @session.check("form_pets_cat")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog', 'cat', 'hamster')
  end

  it "should check a checkbox by label" do
    @session.check("Cat")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog', 'cat', 'hamster')
  end

  it "casts to string" do
    @session.check(:"form_pets_cat")
    @session.click_button('awesome')
    expect(extract_results(@session)['pets']).to include('dog', 'cat', 'hamster')
  end

  context "with a locator that doesn't exist" do
    it "should raise an error" do
      msg = "Unable to find checkbox \"does not exist\""
      expect do
        @session.check('does not exist')
      end.to raise_error(Capybara::ElementNotFound, msg)
    end
  end

  context "with a disabled checkbox" do
    it "should raise an error" do
      expect do
        @session.check('Disabled Checkbox')
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with :exact option" do
    it "should accept partial matches when false" do
      @session.check('Ham', :exact => false)
      @session.click_button('awesome')
      expect(extract_results(@session)['pets']).to include('hamster')
    end

    it "should not accept partial matches when true" do
      expect do
        @session.check('Ham', :exact => true)
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "with `option` option" do
    it "can check boxes by their value" do
      @session.check('form[pets][]', :option => "cat")
      @session.click_button('awesome')
      expect(extract_results(@session)['pets']).to include('cat')
    end

    it "should raise an error if option not found" do
      expect do
        @session.check('form[pets][]', :option => "elephant")
      end.to raise_error(Capybara::ElementNotFound)
    end
  end

  context "when checkbox hidden" do
    it "should check via clicking the label with :for attribute if possible" do
      expect(@session.find(:checkbox, 'form_cars_tesla', unchecked: true, visible: :hidden)).to be
      @session.check('form_cars_tesla')
      @session.click_button('awesome')
      expect(extract_results(@session)['cars']).to include('tesla')
    end

    it "should check via clicking the wrapping label if possible" do
      expect(@session.find(:checkbox, 'form_cars_mclaren', unchecked: true, visible: :hidden)).to be
      @session.check('form_cars_mclaren')
      @session.click_button('awesome')
      expect(extract_results(@session)['cars']).to include('mclaren')
    end

    it "should not click the label if unneeded" do
      expect(@session.find(:checkbox, 'form_cars_jaguar', checked: true, visible: :hidden)).to be
      @session.check('form_cars_jaguar')
      @session.click_button('awesome')
      expect(extract_results(@session)['cars']).to include('jaguar')
    end

    it "should raise original error when no label available" do
      expect { @session.check('form_cars_ariel') }.to raise_error(Capybara::ElementNotFound, 'Unable to find checkbox "form_cars_ariel"')
    end

    it "should raise error if not allowed to click label" do
      expect{@session.check('form_cars_mclaren', click_label: false)}.to raise_error(Capybara::ElementNotFound, 'Unable to find checkbox "form_cars_mclaren"')
    end
  end
end
