<?php

namespace App\Http\Controllers\Api\V1\Auth;


use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\CentralLogics\Helpers;


class CustomerAuthController extends Controller
{
    
     public function login(Request $request) {
        
        $validator = Validator::make($request->all(), [
            'wa' => "required",
            'password' => 'required|min:6'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => Helpers::error_processor($validator)], 403);
        }

        $data = [
            'wa' => $request->wa,
            'password' => $request->password
        ];

        if(auth()->attempt($data)) {
            //auth()->user() is coming from laravel auth:api middleware
            $token = auth()->user()->createToken('CustomerAuth')->accessToken;
            if(!auth()->user()->status) {
                $errors = [];
                array_push($errors, ['code' => 'auth-003', 'message'=>trans('message.your_account_is_blocked')]);
                return response()->json([
                    'errors' => $errors
                ], 401);
            }

            return response()->json(['token' => $token, 'is_phone_verified'=>auth()->user()->is_phone_verified], 200);
        } else {
            $errors = [];
            array_push($errors, ['code' => 'auth-001', 'message' => 'Unauthorized.']);
            return response()->json([
                'errors' => $errors
            ], 401);
        }
     }
    
        public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'f_name' => 'required',
            //'l_name' => 'required',
            'email' => 'required|unique:users',
            'wa' => 'required|unique:users',
            'password' => 'required|min:6',
        ], [
            'f_name.required' => 'The first name field is required.',
            'wa.required' => 'The  phone field is required.',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => Helpers::error_processor($validator)], 403);
        }
        $user = User::create([
            'f_name' => $request->f_name,
            //'l_name' => $request->l_name,
            'email' => $request->email,
            'wa' => $request->wa,
            'password' => bcrypt($request->password),
        ]);

        $token = $user->createToken('CustomerAuth')->accessToken;

       
        return response()->json(['token' => $token,'is_phone_verified' => 0, 'phone_verify_end_url'=>"api/v1/auth/verify-phone" ], 200);
    }
}
