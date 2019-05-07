# frozen_string_literal: true

require 'base64'
require 'benchmark'

describe 'token related end-points and headers', :transaction do
  before(:each) do
    @attributes = build(:user, :with_credentials)
    creation = create_user @attributes
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  describe 'login with HTTP_AUTHORIZATION Basic' do
    before(:each) do
      built = build(:user, :with_credentials)
      @wrong_login = built[:login]
      @wrong_password = built[:password]
      @good_login = @attributes[:login]
      @good_password = @attributes[:password]
    end

    context 'when HTTP_AUTHORIZATION is missing' do
      it 'should return 401 Unauthorized' do
        header 'authorization', "trololololo"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end
    context 'when HTTP_AUTHORIZATION is garbage' do
      it 'should return 401 Unauthorized' do
        header 'authorization', "trololololo"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when HTTP_AUTHORIZATION is Basic garbage' do
      it 'should return 401 Unauthorized' do
        header 'authorization', "Basic trololololo"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when the password is wrong' do
      it 'should return 401 Unauthorized' do
        auth = Base64.encode64("#{@good_login}:#{@wrong_password}")
        header 'authorization', "Basic #{auth}"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when the login is wrong' do
      it 'should return 401 Unauthorized' do
        auth = Base64.encode64("#{@wrong_login}:#{@good_password}")
        header 'authorization', "Basic #{auth}"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end

      describe 'timing' do
        before(:all) do
          @cost = Benchmark.realtime do
            Sanchin::Container['password'].create 'secret'
          end
        end

        it 'should take about the same time as when the password is wrong' do
          auth = Base64.encode64("#{@good_login}:#{@wrong_password}")
          header 'authorization', "Basic #{auth}"
          ref = Benchmark.realtime { post '/api/v1/tokens' }
          auth = Base64.encode64("#{@wrong_login}:#{@good_password}")
          header 'authorization', "Basic #{auth}"
          spent = Benchmark.realtime { post '/api/v1/tokens' }
          expect((ref - spent).abs).to be < @cost
        end
      end

      it 'should return 201 Created' do
        auth = Base64.encode64("#{@good_login}:#{@good_password}")
        header 'authorization', "Basic #{auth}"
        post '/api/v1/tokens'
        expect(last_response.status).to eq(201)
        expect(json_body[:token_type]).to eq('bearer')
        expect(json_body[:access_token]).to eq(@token)
      end
    end
  end

  describe 'API call with HTTP_AUTHORIZATION Bearer' do
    context 'when HTTP_AUTHORIZATION is missing' do
      it 'should return 401 Unauthorized' do
        header 'authorization', "trololololo"
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when HTTP_AUTHORIZATION is garbage' do
      it 'should return 401 Unauthorized' do
        header 'authorization', "trololololo"
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when it is not a Bearer token' do
      it 'should return 401 Unauthorized' do
        auth = Base64.encode64('Aladdin:OpenSesame')
        header 'authorization', "Basic #{auth}"
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when it is not a valid Bearer token' do
      it 'should return 401 Unauthorized' do
        header 'authorization', 'Bearer trololololo'
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when it is a token for a removed user' do
      before(:each) do
        result = destroy_user(@current_user.id)
        expect(result).to be_success
      end
      it 'should return 401 Unauthorized' do
        header 'authorization', "Bearer #{@token}"
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end

    context 'when it is an outdated token' do
      before(:each) do
        result = update_user(@current_user.id, firstname: 'john')
        expect(result).to be_success
      end
      it 'should return 401 Unauthorized' do
        header 'authorization', "Bearer #{@token}"
        get "/api/v1/users/#{@current_user.id}"
        expect(last_response.status).to eq(401)
        expect(last_response.body).to be_empty
      end
    end
  end
end
