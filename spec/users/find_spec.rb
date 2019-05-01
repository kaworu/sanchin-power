# frozen_string_literal: true

describe 'users find end-point', :transaction do
  before(:each) do
    result = create_user.call build(:user)
    expect(result).to be_success
    @user = result.value!
  end

  context 'when given malformed id' do
    it 'should return 404 Not Found' do
      get '/api/v1/users/foo'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end
  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      get "/api/v1/users/#{SecureRandom.uuid}"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'when given a valid id' do
    it 'should return the matching user' do
      get "/api/v1/users/#{@user.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to eq(hiphop(@user))
    end
    context 'with an up-to-date resource' do
      it 'should return 304 Not Modified' do
        header 'if-modified-since', @user.updated_at.httpdate
        get "/api/v1/users/#{@user.id}"
        expect(last_response.status).to eq(304)
        expect(last_response.body).to be_empty
      end
    end
    context 'with a stale resource' do
      it 'should return the matching user' do
        header 'if-modified-since', (@user.updated_at - 1).httpdate
        get "/api/v1/users/#{@user.id}"
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body).to eq(hiphop(@user))
      end
    end
  end
end
