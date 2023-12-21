// data_generator.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ExpenseManager/util/message_util.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import 'salesforce_util.dart';
import 'package:device_info/device_info.dart';

class DataGenerator {

  static String customEndpointForSyncMessages       = '/services/apexrest/FinPlan/api/sms/sync/*';
  static String customEndpointForApproveMessages    = '/services/apexrest/FinPlan/api/sms/approve/*';
  static String customEndpointForDeleteMessages     = '/services/apexrest/FinPlan/api/sms/delete/*';
  static String customEndpointForDeleteTransactions = '/services/apexrest/FinPlan/api/transactions/delete/*';
  static String customEndpointForDeleteAllMessagesAndTransactions = '/services/apexrest/FinPlan/api/delete/*';

  static Logger log = Logger();

  static Future<List<List<String>>> generateTab1Data() async {
    List<List<String>> generatedDataTab1 = [];

    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'FinPlan__Received_At_formula__c', 'FinPlan__Transaction_Date__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'FinPlan__Received_At_formula__c desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    log.d('Error inside generateTab1Data : ${error.toString()}');
    log.d('Datainside generateTab1Data: ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        log.d('here 0');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            
            String id = recordMap['Id'];
            log.d('1 -Id $id');
            
            String beneficiary = recordMap['FinPlan__Beneficiary__c'];
            log.d('2 -beneficiary $beneficiary');
            
            String amount = (recordMap['FinPlan__Formula_Amount__c'] != null) ? recordMap['FinPlan__Formula_Amount__c'].toString() : 'N/A' ;
            log.d('3 -amount $amount');
            
            String date = recordMap['FinPlan__Transaction_Date__c'].substring(5,10);
            log.d('3 -date $date');
            String formattedDate = '${date.split('-')[1]}/${date.split('-')[0]}';
            
            generatedDataTab1.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error Inside generateTab1Data : $error');
      }
    }
    log.d('Inside generateTab1Data=>$generatedDataTab1');
    return generatedDataTab1;
  }
  
  static Future<List<List<String>>> generateTab2Data(DateTime startDate, DateTime endDate) async {
    log.d('here 1');
    log.d('Inside generate tab2 data, startDate date is => $startDate');
    log.d('Inside generate tab2 data, endDate date is => $endDate');
    String formattedStartDate = startDate.toString().split(' ')[0];
    String formattedEndDate = endDate.toString().split(' ')[0];
    List<List<String>> generatedDataTab2 = [];
    log.d('here 2');
    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Transaction__c', 
      fieldList: ['Id', 'FinPlan__Beneficiary_Name__c','FinPlan__Transaction_Date__c', 'FinPlan__Amount__c','FinPlan__Type__c'],
      whereClause: 'FinPlan__Transaction_Date__c >= $formattedStartDate AND FinPlan__Transaction_Date__c <= $formattedEndDate ',
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
    );
    log.d('here 3');
    dynamic error = response['error'];
    dynamic data = response['data'];

    log.d('Error: ${error.toString()}');
    log.d('Data inside : ${data.toString()}');
    log.d('here 4');
    if(error != null && error.isNotEmpty){
      log.d('Error occurred while querying inside generateTab2Data : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        dynamic records = data['data'];
        if (records != null && records.isNotEmpty) {
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            String id = recordMap['Id'];
            String beneficiary = recordMap['FinPlan__Beneficiary_Name__c'];
            String amount = recordMap['FinPlan__Amount__c'].toString();
            String rawDate = recordMap['FinPlan__Transaction_Date__c']; //.substring(5,10);
            String formattedDate = '${rawDate.split('-')[2]}/${rawDate.split('-')[1]}';

            log.d('beneficiary $beneficiary || amount $amount || rawDate $rawDate || id $id');

            generatedDataTab2.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error inside generateTab2Data : $error');
      }
    }
    log.d('Inside generateTab2Data=>$generatedDataTab2');
    return generatedDataTab2;
  } 
 
  static Future<List<List<String>>> generateTab3Data() async{
    List<List<String>> generatedDataTab3 = [];

    Map<String, dynamic> response = await SalesforceUtil.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Account__c',
      fieldList: ['Id', 'FinPlan__Account_Code__c', 'Name', 'FinPlan__Last_Balance__c', 'FinPlan__CC_Available_Limit__c', 'FinPlan__CC_Max_Limit__c', 'LastModifiedDate'], 
      // whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'LastModifiedDate desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    log.d('Error inside generateTab1Data : ${error.toString()}');
    log.d('Datainside generateTab1Data: ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        log.d('here 0');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            
            String id = recordMap['Id'];            
            String accountCode = recordMap['FinPlan__Account_Code__c'] ?? 'N/Av';  

            String amount = accountCode.contains('-CC') 
              ? NumberFormat.currency(locale: 'en_IN').format(recordMap['FinPlan__CC_Available_Limit__c'] ?? 0)
              : NumberFormat.currency(locale: 'en_IN').format(recordMap['FinPlan__Last_Balance__c'] ?? 0);
            
            String time = '';
            String lastmodifiedDate = recordMap['LastModifiedDate'].toString(); // example 2023-12-12T19:56:13.000+0000
            if(lastmodifiedDate.contains('T')){
              String hhmmss = lastmodifiedDate.split('T')[1].split('.')[0];
              String date = lastmodifiedDate.split('T')[0];
              time = hhmmss;
            }
            
            log.d('accountCode $accountCode || amount $amount || time $time || id $id');

            generatedDataTab3.add([accountCode, amount, time, id]);
          }
        }
      }
      catch(error){
        log.d('Error Inside generateTab3Data : $error');
      }
    }
    log.d('Inside generateTab3Data=>$generatedDataTab3');
    return generatedDataTab3;
  }

  static Future<Map<String, dynamic>> addExpenseToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    
    List<Map<String, dynamic>> data = [];
    
    Map<String, dynamic> each = {};
    each['FinPlan__Amount_Value__c'] = amount;
    each['FinPlan__Beneficiary__c'] = paidTo;
    each['FinPlan__Content__c'] = details;
    each['FinPlan__Received_At__c'] = selectedDate.toString();
    each['FinPlan__Sender__c'] = 'N/A';

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String deviceName = androidInfo.model;
    each['FinPlan__Device__c'] = deviceName;

    data.add(each);

    Map<String, dynamic> response =  await SalesforceUtil.dmlToSalesforce(opType: 'insert',objAPIName: 'FinPlan__SMS_Message__c', fieldNameValuePairs: data);
    return response;
    
  }

  // Custom REST Endpoints
  static Future<Map<String, dynamic>> deleteAllMessagesAndTransactions() async {
    String response = await SalesforceUtil.callSalesforceAPI(
        endpointUrl: customEndpointForDeleteAllMessagesAndTransactions,
        httpMethod: 'POST'
    );
    return jsonDecode(response);
  }

  static Future<Map<String, dynamic>> approveSelectedMessages({required String objAPIName, required List<String> recordIds}) async {
    dynamic body = {
      'input' : {
        'data': recordIds
      }
    };
    
    String responseString = 
        await SalesforceUtil.callSalesforceAPI
          (httpMethod: 'POST', 
          endpointUrl: customEndpointForApproveMessages, 
          body : body);

    Map<String, dynamic> response = json.decode(responseString);
    return response;
  } 

  static Future<Map<String, dynamic>> syncMessages() async{
    
    List<SmsMessage> messages = await MessageUtil.getMessages();//count : 200); // Change this while debugging
    List<Map<String, dynamic>> processedMessages = await MessageUtil.convert(messages);
    
    // TB Implemented
    // Map<String, dynamic> transactionsDeleteResponse = await SalesforceUtil.callSalesforceAPI(httpMethod: 'DELETE', endpointUrl: customEndpointForDeleteTransactions, body: {});
    // log.d('transactionsDeleteResponse response IS->$transactionsDeleteResponse');
    
    Map<String, dynamic> response = await SalesforceUtil.dmlToSalesforce(
        opType: 'insert',
        objAPIName : 'FinPlan__SMS_Message__c', 
        fieldNameValuePairs : processedMessages);

    log.d('SMS Created response Data => ${response['data'].toString()}');
    log.d('SMS Created response Errors => ${response['errors'].toString()}');

    return response;
  }

  
}
