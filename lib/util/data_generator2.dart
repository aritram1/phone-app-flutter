// data_generator.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import './salesforce_util2.dart';
// import './salesforce_util.dart';
// import 'package:device_info/device_info.dart';

class DataGenerator2 {
  static Logger log = Logger();

  static Future<List<List<String>>> generateTab1Data() async {
    List<List<String>> generatedData = [];

    Map<String, dynamic> response = await SalesforceUtil2.queryFromSalesforce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'FinPlan__Received_At_formula__c', 'FinPlan__Transaction_Date__c', 'FinPlan__Beneficiary__c', 'FinPlan__Amount_Value__c', 'FinPlan__Formula_Amount__c'], 
      whereClause: 'FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true AND FinPlan__Formula_Amount__c > 0',
      orderByClause: 'FinPlan__Received_At_formula__c desc',
      //count : 120
      );
    String? error = response['error'];
    String? data = response['data'];

    log.d('Error: $error');
    log.d('Data: $data');
    
    if(error != null){
      log.d('Error occurred while querying inside generateTab1Data : ${response['error']}');
      //return null;
    }
    else if (data != null) {
      try{
        Map<String, dynamic> jsonData = json.decode(data);
        if (jsonData['records'] != null) {
          log.d('response in generateTab1Data -> $jsonData');
          List<dynamic> records = jsonData['records'];
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
            
            generatedData.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error Inside generateTab1Data : $error');
      }
    }
    log.d('Inside generateTab1Data=>$generatedData');
    return generatedData;
  } 

  static Future<List<List<String>>> generateTab2Data(DateTime startDate, DateTime endDate) async {
    log.d('here 1');
    log.d('Inside generate tab2 data, startDate date is => $startDate');
    log.d('Inside generate tab2 data, endDate date is => $endDate');
    String formattedStartDate = startDate.toString().split(' ')[0];
    String formattedEndDate = endDate.toString().split(' ')[0];
    List<List<String>> generatedData = [];
    log.d('here 2');
    Map<String, dynamic> response = await SalesforceUtil2.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Transaction__c', 
      fieldList: ['Id', 'FinPlan__Beneficiary_Name__c','FinPlan__Transaction_Date__c', 'FinPlan__Amount__c','FinPlan__Type__c'],
      whereClause: 'FinPlan__Transaction_Date__c >= $formattedStartDate AND FinPlan__Transaction_Date__c <= $formattedEndDate ',
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
      );
      log.d('here 3');
    String? error = response['error'];
    String? data = response['data'];

    log.d('Error: $error');
    log.d('Data: $data');
    log.d('here 4');
    if(error != null){
      log.d('Error occurred while querying inside generateTab2Data : ${response['error']}');
      //return null;
    }
    else if (data != null) {
      try{
        Map<String, dynamic> jsonData = json.decode(data);
        if (jsonData['records'] != null) {
          log.d('response in generateTab2Data -> $jsonData');
          List<dynamic> records = jsonData['records'];
          log.d('records $records');
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            String id = recordMap['Id'];
            String beneficiary = recordMap['FinPlan__Beneficiary_Name__c'];
            String amount = recordMap['FinPlan__Amount__c'].toString();
            String rawDate = recordMap['FinPlan__Transaction_Date__c']; //.substring(5,10);
            String formattedDate = '${rawDate.split('-')[2]}/${rawDate.split('-')[1]}';

            log.d('beneficiary $beneficiary || amount $amount || rawDate $rawDate || id $id');            
            generatedData.add([beneficiary, amount, formattedDate, id]);
          }
        }
      }
      catch(error){
        log.d('Error inside generateTab2Data : $error');
      }
    }
    log.d('Inside generateTab2Data=>$generatedData');
    return generatedData;
  } 
 

  static List<List<String>> generateTab3Data() {
    // Replace this with your data generation logic
    List<List<String>> data = List.generate(100, (index) {
      return [
        'T3 Row ${index + 1}',
        'Data ${(index + 1) * 2}',
        'Info ${(index + 1) * 3}',
      ];  
    });
    return data;
  }

  /*
  static Future<String> addExpenseToSalesforce(String amount, String paidTo, String details, DateTime selectedDate) async {
    List<Map<String, dynamic>> data = [];
    Map<String, dynamic> each = {};

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String deviceName = androidInfo.model;

    each['FinPlan__Amount_Value__c'] = amount;
    each['FinPlan__Beneficiary__c'] = paidTo;
    each['FinPlan__Content__c'] = details;
    each['FinPlan__Received_At__c'] = selectedDate.toString();
    each['FinPlan__Sender__c'] = 'N/A';
    each['FinPlan__Device__c'] = deviceName;

    data.add(each);
    return await SalesforceUtil.saveToSalesForce('FinPlan__SMS_Message__c', data);
  }


  static Future<String> deleteAllMessages(String objAPIName) async {
    return await SalesforceUtil.deleteSalesforceData('FinPlan__SMS_Message__c', []); //signature (String objAPIName, List RecordIds)
  }

  static Future<String> approveSelectedMessages(String objAPIName, List<String> recordIds) async {
    String response = await SalesforceUtil.updateSalesforceData('FinPlan__SMS_Message__c', recordIds);
    return response;
  } 
  */
  
}
