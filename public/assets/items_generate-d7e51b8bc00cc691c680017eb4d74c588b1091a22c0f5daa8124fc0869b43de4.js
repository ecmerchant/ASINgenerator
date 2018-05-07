// create table for ASIN

var maxColnum = 1;
var maxRownum = 9600;
var mydata = [];
var colOption = [];
for(var i = 0; i < maxRownum; i++){
  mydata[i] = [];
  for(var j = 0; j < maxColnum; j++){
    mydata[i][j] = "";
  }
}


var container = document.getElementById('result');
var handsontable = new Handsontable(container, {
  /* オプション */
  width: 240,
  height: 400,
  contextMenu: true,
  data: mydata,
  rowHeaders: true,
  colHeaders: ["ASIN"],
  maxCols: maxColnum,
  maxRows: maxRownum,
  manualColumnResize: true,
  autoColumnSize: false,
  colWidths:[160]
});


$("#submit_url").click(function () {

  alert("アクセス増加のため動作が不安定です。ご迷惑をおかけしています。有料版のエクセルツールでは引き続き、日本、アメリカ、オーストラリアのASINを取得可能です。");
  //return;

  alert("ASINの取得を開始します");
  var url = document.getElementById("input_url").value;
  var pgnum = 1;
  var cnum = 0;
  handsontable.loadData(mydata);
  repajax(url,pgnum,cnum);
});

function repajax(url,pgnum,cnum){

  var maxnum = document.getElementById("maxnumber").value
  if(maxnum == ""){
    maxnum = 9600;
  }
  maxnum = Number(maxnum);

  var max = 500;
  var min = 100;
  var a = Math.floor( Math.random() * (max + 1 - min) ) + min ;

  maxnum = a;

  var body = [];
  body[0] = url;
  body[1] = pgnum;
  body[2] = maxnum;
  body[3] = cnum;

  body = JSON.stringify(body);
  myData = {data: body};


  $.ajax({
    url: "/items/search",
    type: "POST",
    data: myData,
    dataType: 'json',
    success: function (resData) {
      if(resData == ""){
        alert("終了しました");
        return;
      }
      var org_data = handsontable.getData();
      for(var i = 0; i < org_data.length; i++){
        if(org_data[i][0] == ""){
          org_data.length = i;
          break;
        }
      }

      var ddnum = org_data.length;

      Array.prototype.push.apply(org_data, resData);
      if(org_data.length > maxnum){
        org_data.length = maxnum;
        handsontable.loadData(org_data);
        return;
      }else{
        handsontable.loadData(org_data);
        pgnum++;
        //cnum = cnum + ddnum;
        sleep(500,repajax(url,pgnum,cnum));
        //repajax(url,pgnum,cnum);
      }

    },
    error: function (resData) {
      return false;
    }
  });
}


$("#output").click(function () {
  var tempData = handsontable.getData();
  var csvdata = "";

  for(var k = 0; k < tempData.length; k++){
    csvdata = csvdata + tempData[k][0] + "\n";
  }

  var str_array = Encoding.stringToCode(csvdata);
  //var sjis_array = Encoding.convert(str_array, "SJIS", "UNICODE");
  var uint8_array = new Uint8Array(str_array);

  var blob = new Blob([uint8_array], { "type" : "text/tsv" });
  //var blob = new Blob(["あいうえお"], { "type" : "text/tsv" });

  if (window.navigator.msSaveBlob) {
      window.navigator.msSaveBlob(blob, "list.txt");

      // msSaveOrOpenBlobの場合はファイルを保存せずに開ける
      window.navigator.msSaveOrOpenBlob(blob, "list.txt");
  } else {
      document.getElementById("output").href = window.URL.createObjectURL(blob);
  }
});


function sleep(time, callback){
  setTimeout(callback, time);
}
;
