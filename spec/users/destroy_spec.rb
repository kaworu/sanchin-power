# frozen_string_literal: true

describe 'users destruction end-point', :transaction do
  before(:each) do
    result = create_user.call build(:user)
    expect(result).to be_success
    @user = result.value!
  end

  context 'when given malformed id' do
    it 'should return 404 Not Found' do
      delete '/api/v1/users/foo'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end
  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      delete "/api/v1/users/#{SecureRandom.uuid}"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end

  it 'should delete the matching user' do
    header 'if-unmodified-since', @user.updated_at.httpdate
    delete "/api/v1/users/#{@user.id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to be_empty
    expect(find_user.call(@user.id)).to be_failure
  end

  context 'with a stale resource' do
    it 'should return 412 Precondition Failed' do
      header 'if-unmodified-since', (@user.updated_at - 1).httpdate
      delete "/api/v1/users/#{@user.id}"
      expect(last_response.status).to eq(412)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end

  context 'without HTTP_IF_UNMODIFIED_SINCE' do
    it 'should return 428 Precondition Required' do
      delete "/api/v1/users/#{@user.id}"
      expect(last_response.status).to eq(428)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end

  context 'when HTTP_IF_UNMODIFIED_SINCE is not a HTTP-date' do
    it 'should return 428 Precondition Required' do
      header 'if-unmodified-since', @user.updated_at.iso8601
      delete "/api/v1/users/#{@user.id}"
      expect(last_response.status).to eq(428)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end
end
