<%@ include file="/WEB-INF/template/include.jsp"%>

<openmrs:require privilege="Patient Dashboard - View Drug Order Section" otherwise="/login.htm" redirect="/module/pharmacymanagement/storequest.form"/>

<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/jquery.dataTables1.js" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/jquery.simplemodal1.js" />
<!-- openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/jquery.createdit.js" /-->
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/basic1.js" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/jquery.PrintArea.js" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/create_dynamic_field.js" />

<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/demo_page1.css" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/demo_table1.css" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/basic1.css" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/dataentrystyle.css" />
<openmrs:htmlInclude file="/moduleResources/@MODULE_ID@/scripts/chosen.css" />

<script type="text/javascript">

	// drugs options
    var drugsName = new Array();
    var drugsId = new Array();
    <c:forEach var="drug" items="${model.drugMap}">
    	drugsName.push('<c:out value="${drug.value}"/>');
    	drugsId.push('<c:out value="${drug.key}"/>');    
    </c:forEach>

    var drName = ""; 
	<c:forEach var="ord" items="${model.drugOrders}" varStatus="status">
		var count = '<c:out value="${status.count}"/>'; 
		if(count > 1) {
			drName += ", ";
		}
		drName += '<c:out value="${ord.drugOrder.drug.name}"/>';
	</c:forEach>
	
	jQuery(document).ready( function() {
		jQuery('.searchBox').hide();
		oTable = jQuery('#example_do').dataTable({
			"fnDrawCallback": function ( oSettings ) {
				if ( oSettings.aiDisplay.length == 0 )
				{
					jQuery('table#example_do').css({'width':'100%'});
					return;
				}

				var nTrs = jQuery('tbody tr', oSettings.nTable);
				jQuery('table#example_do').css({'width':'100%'});
				var iColspan = nTrs[0].getElementsByTagName('td').length;
				var sLastGroup = "";
				for ( var i=0 ; i<nTrs.length ; i++ )
				{
					var iDisplayIndex = oSettings._iDisplayStart + i;
					var sGroup = oSettings.aoData[ oSettings.aiDisplay[iDisplayIndex] ]._aData[0];
					if ( sGroup != sLastGroup )
					{
						var nGroup = document.createElement( 'tr' );	
						var nCell = document.createElement( 'td' );
						nCell.colSpan = iColspan;
						nCell.className = "group";
						nCell.innerHTML = sGroup;
						nGroup.appendChild( nCell );
						nTrs[i].parentNode.insertBefore( nGroup, nTrs[i] );
						sLastGroup = sGroup;
					}
				}
			},
			"aoColumnDefs": [
				{ "bVisible": false, "aTargets": [ 0 ] }
			],
			"aaSortingFixed": [[ 0, 'asc' ]],
			"aaSorting": [[ 1, 'asc' ]],
			"sDom": 'lfr<"giveHeight"t>ip'
		});

		jQuery('.edit').click( function() {
			jQuery('.toBRepl').hide();
			var drugsOption = '<option value="">-- Drugs --</option>';			
			for(var i = 0; i < drugsName.length; i++) {
				drugsOption += '<option value="'+drugsId[i]+'">'+drugsName[i]+'</option>';
			}
			jQuery('#dname').html(drugsOption);
			var index = this.id;
			var prefix = index.substring(0, index.indexOf("_"));
			var suffix = index.substring(index.indexOf("_") + 1);

			var varDose = jQuery("#dose_" + suffix).text();
			var drugId = jQuery("#drugId_" + suffix).text().trim();
			var varUnits = jQuery("#units_" + suffix).text();
			var varQuantity = jQuery("#quantity_" + suffix).text();
			var varStartDate = jQuery("#startDate_" + suffix).text();
			var varDiscDate = jQuery("#discontinuedDate_" + suffix).text();
			var varInstructions = jQuery("#instructions_" + suffix).val();
			
			var varFrequency = jQuery("#frequency_" + suffix).text();
			var varFrequencyArray = varFrequency.split('X');
			var freqDrugQty = varFrequencyArray[0];
			var freqTimesperday = varFrequencyArray[1];
			var freqDays = varFrequencyArray[2];
			jQuery('#qtyTakenAtOnceId').val(freqDrugQty).attr('selected', true);
			jQuery('#timesPerDayId').val(freqTimesperday).attr('selected',true);
			jQuery('#daysId').val(freqDays).attr('selected',true);

			jQuery("#editing").attr("value", suffix);
			
			jQuery('#dname').val(drugId).attr('selected', true);							
			jQuery("#dquantity").attr("value", varQuantity);
			jQuery("#dstartDate").attr("value", varStartDate);
			jQuery("#ddiscontinuedDate").attr("value", varDiscDate);
			jQuery("#dinstructions").html(varInstructions);
			jQuery("#editingcreating").attr("value", "edit");
			});

		jQuery('.stop').click( function() {
			var index = this.id;
			var prefix = index.substring(0, index.indexOf("_"));
			var suffix = index.substring(index.indexOf("_") + 1);
			var stopDate = jQuery("#discontinuedDate_" + suffix).text();
			var varReason = document.getElementById("stopReasonId");
			var reason = jQuery("#discontinuedReason_" + suffix).text().trim();
			
			jQuery('#stopReasonId').val(reason).attr('selected', true);
			
			jQuery('#stopDateId').attr("value", stopDate);
			jQuery("#stopping").attr("value", suffix);
			jQuery("#stop").attr("value", "stop");
		});

		jQuery('#create').click(function() {
			jQuery("#editingcreating").attr("value", "create");
			var item = '';
			jQuery('#dname').change(function() {
				jQuery.getJSON('${pageContext.request.contextPath}/module/pharmacymanagement/drugSolde.htm?drugId='+jQuery("#dname").val(), function(data) {
					if(data[0].solde == 0) {
						item = 'No Such drug in store';
						jQuery('#soldeId').html(item).css('color','red');
					} else {
						item = 'Solde: ' + data[0].solde;
						jQuery('#soldeId').html(item).css('color','black');
					}
					
					
				});
			});
			jQuery('#dname').chosen({no_results_text: "No results matched"});
		});		
		
		jQuery('#print_ordonance').click(function() {
			var row = null;
			var s = '';
			var tableObject = null;
			var columns = jQuery('#example_do thead th').map(function() {
				return jQuery(this).text();
			});		
			tableObject = jQuery('#example_do tbody tr').map(function(i) {
				row = {};
				jQuery(this).find('td').each(function(i) {
					var rowName = columns[i];
				    row[rowName] = jQuery(this).text();
				    s += jQuery(this).text()+',';
				});
				s += ';';
			});
			var res = s.split(';');
			var tmpArr = null;
			var tmpStr = '';
			var count = 1;
			var date = '';
			var dose = '';
			var units = '';
			var frequency = '';
			var patientName = jQuery('#patientHeaderPatientName').text();
			for(var k = 0; k < res.length; k++) {
				tmpArr = res[k].split(',');
				for(var j = 0; j < tmpArr.length; j++) {
					if(tmpArr.length < 5) {
						break;
					}
					else {
						if(j == 1) {
							tmpStr = '<td height="30" align="left" style="background-color:#E5E5FF;">' + count + '. ' + tmpArr[j] + '</td>';
							date = tmpArr[6];
							tmpStr += '<td align="center" style="background-color:#E5E5FF;">' + tmpArr[2] + '</td>';
							tmpStr += '<td align="center" style="background-color:#E5E5FF;">' + tmpArr[3] + '</td>';
							tmpStr += '<td align="center" style="background-color:#E5E5FF;">' + tmpArr[4] + '</td>';
							tmpStr += '<td align="center" style="background-color:#E5E5FF;">' + tmpArr[5] + '</td>';
							tmpStr += '<td style="background-color:#E5E5FF;">&nbsp;</td><td style="background-color:#E5E5FF;">&nbsp;</td>';
							jQuery('#presc-drugs'+count).html(tmpStr);
							count++
						}
					}
				}
			}

			if(count > 5) {
				alert("More than 4 are not allowed");
			} else {
				jQuery('#presc-drugs').html(tmpStr);
				jQuery('#dateId').html(date);
				jQuery("#ordonance-modal-content").dialog({'width':'70%'});
				//jQuery("#ordonance-modal-content").css({'width':'100%', 'height':'405px'});
				//jQuery("#createditdialog-container").css({'width':'650px', 'height':'500px'});
				//jQuery("#createditdialog-container").css({'top':'120px'});
				jQuery("#createditdialog-container").css({'background-color':'#ffffff'});
			}
		});
		
		jQuery("#print_button").click(function() {
			jQuery(".printArea").printArea();
		});


		jQuery('#medSetId').change(function() {
			var medSetId = jQuery('#medSetId');
			var sb = '<option value="">--Concept--</option>';
			jQuery.getJSON('${pageContext.request.contextPath}/module/pharmacymanagement/conceptdrug.htm?medSet=' + medSetId.val(), function(data) {				
				for(var i in data) {
					sb += '<option value="'+data[i].id+'">'+data[i].name+'</option>';
				}
				jQuery("#drugConceptId").html(sb);
			});
		});

		jQuery('#drugConceptId').change(function() {
			var drugConceptId = jQuery('#drugConceptId');
			var sb1 = '<option value="">--Concept--</option>';
			var opt = '';
			jQuery.getJSON('${pageContext.request.contextPath}/module/pharmacymanagement/conceptdrug.htm?drugConcept=' + drugConceptId.val(), function(data) {
				for(var i in data) {
					opt = '<span class="" ><option value="'+data[i].id+'">'+data[i].name+'</option></span>';
					for(var j in drugsId) {
						if(drugsId[j] == data[i].id) {
							sb1 += '<span class="in_store" ><option value="'+data[i].id+'">'+data[i].name+'</option></span>';
							break;
						} else {							
							sb1 += '<span class="not_in_store" ><option value="'+data[i].id+'">'+data[i].name+'</option></span>';
							break;
						}
					}				
				}
				jQuery('.not_in_store').css({'color':'red'});
				jQuery("#dname").html(sb1);
			});
		});
		
		jQuery('#daysId').change(function() {
			var qtyTakenAtOnce = jQuery('#qtyTakenAtOnceId').val();
			var timesPerDay = jQuery('#timesPerDayId').val();
			var days = jQuery('#daysId').val();
			var quantity = qtyTakenAtOnce * timesPerDay * days;
			
			jQuery('#frequencyId').val(qtyTakenAtOnce + 'X' + timesPerDay + 'X' + days);
			
			jQuery('#dquantity').val(quantity);
		});
		
	});
</script>

<div id="dt_example">
<div id="container">

<div style="float: right"><img id="print_ordonance" src="moduleResources/@MODULE_ID@/images/print_preview.gif" style="cursor: pointer;" title="Print Preview" /></div>
<table cellpadding="0" cellspacing="0" border="0" class="display"
	id="example_do" style="width:100%">
	<thead>
		<tr>
			<th>Rendering engine</th>
			<th><spring:message code="@MODULE_ID@.drugId" /></th>
			<th><spring:message code="@MODULE_ID@.drug" /></th>
			<th><spring:message code="@MODULE_ID@.dose" /></th>
			<th><spring:message code="@MODULE_ID@.units" /></th>
			<th><spring:message code="@MODULE_ID@.frequency" /></th>
			<th><spring:message code="@MODULE_ID@.quantity" /></th>
			<th><spring:message code="@MODULE_ID@.startDate" /></th>
			<th><spring:message code="@MODULE_ID@.stopDate" /></th>
			<th><spring:message code="Stopped Reason" /></th>
			<th><spring:message code="Revise/Clone" /></th>
			<th><spring:message code="@MODULE_ID@.stop" /></th>
		</tr>
	</thead>
	<tbody>
		<c:forEach items="${model.map}" var="key" varStatus="num">
			<c:forEach items="${key.value}" var="do" varStatus="num1">
			<tr>
				<td><openmrs:formatDate date="${key.key}" type="textbox" /></td>
				<td>
					<input type="hidden" id="instructions_${do.drugOrder.orderId}" value="${do.drugOrder.dosingInstructions}" /> 
					<span id="drugId_${do.drugOrder.orderId}">${do.drugOrder.drug.drugId}</span>
				</td>
				<td><span id="name_${do.drugOrder.orderId}">${not empty do.drugOrder.drug ? do.drugOrder.drug.name : do.concept}</span></td>
				<td><span id="dose_${do.drugOrder.orderId}">${do.drugOrder.dose}</span></td>
				<td><span id="units_${do.drugOrder.orderId}">${do.doseUnitsName}</span></td>
				<td><span id="frequency_${do.drugOrder.orderId}">${do.drugOrder.frequency.name}</span></td>
				<td><span id="quantity_${do.drugOrder.orderId}">${do.drugOrder.quantity}</span></td>
				<td><span id="startDate_${do.drugOrder.orderId}"><openmrs:formatDate date="${do.startDate}" type="textbox" /></span></td>
				<td>
					<c:choose>
						<c:when test="${do.isActive ne null && do.isActive eq false}">
							<span id="discontinuedDate_${do.drugOrder.orderId}"><openmrs:formatDate date="${do.stopDate}" type="textbox" /></span>
					</c:when>
						<c:otherwise>
							<!-- TODO do what? -->
						</c:otherwise>
					</c:choose>
				</td>
				<td>
					<c:choose>
						<c:when test="${do.isActive ne null && do.isActive eq false}">
							<span id="discontinuedReason_${do.drugOrder.orderId}">${do.orderReason}</span>
						</c:when>
						<c:otherwise>
							<!-- TODO do what? -->
						</c:otherwise>
					</c:choose>
				</td>
				<td>
					<c:choose>
						<c:when test="${do.isActive ne null && do.isActive eq true}">
							<img id="edit_${do.drugOrder.orderId}" class="edit" src="${pageContext.request.contextPath}/images/edit.gif" style="cursor: pointer" title="Edit" />
						</c:when>
						<c:otherwise>
							<!-- TODO do what? -->
						</c:otherwise>
					</c:choose>
				</td>
				<td>
					<c:choose>
						<c:when test="${do.isActive ne null && do.isActive eq true}">
							<img id="stop_${do.drugOrder.orderId}" class="stop" src="${pageContext.request.contextPath}/images/stop.gif" style="cursor: pointer;" title="Stop" />
						</c:when>
						<c:otherwise>
							<!-- TODO do what? -->
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
			</c:forEach>
		</c:forEach>
	</tbody>
	<tfoot>
		<tr>
			<td></td>
			<td></td>
			<td></td>
			<td></td>
			<td></td>
			<td></td>			
			<td>
			<button id="create" class="send"><spring:message
				code="pharmacymanagement.create" /></button>
			</td>
			<td></td>
		</tr>
	</tfoot>
</table>
</div>
</div>

<div id="edit-dialog-content">
<form method="post" action="module/@MODULE_ID@/dopc.form">
<input type="hidden" name="orderId" id="editing" />
<input type="hidden" name="editcreate" id="editingcreating" />

<!-- Just created these two parameters in order to get them as they are in the Controller (KAMONYO)-->
<input type="hidden" name="appointmentId" value="${model.appointmentId}" />
<input type="hidden" name="patientId" value="${model.patientId}" />
<!-- End of this -->

<table>
	<tr>
		<td><spring:message code="Drug Details" /></td>
		<td>
			<select name="drugs" id="dname" style="width:500px;">
				<option value="">--Drug--</option>
				<c:forEach items="${model.drugs}" var="drug">
					<option value="${drug.drugId}">${drug.name}</option>
				</c:forEach>
			</select>
		</td>
		<td id="soldeId"></td>
	</tr>
	<tr>
		<td><spring:message code="pharmacymanagement.frequency" /></td>
		<td>
			<select name="frequency" id="dfrequency">
				<c:forEach items="${model.orderFrequencies}" var="dFreq">
					<option value="${dFreq.orderFrequency.uuid}">${dFreq.name}</option>
				</c:forEach>
			</select>
		</td>
	<tr>
		<td><spring:message code="pharmacymanagement.startDate" /></td>
		<td><input id="dstartDate" type="text" name="startdate" onfocus="showCalendar(this)" onchange="CompareDates('<openmrs:datePattern />', 'dstartDate');" class="date" size="11" />(dd/mm/yyyy)
		<span id="msgId" style="width"></span></td>
	</tr>
	<tr>
		<td>Stop Date</td>
		<td><input id="ddiscontinuedDate" type="text" name="stopdate"
			onfocus="showCalendar(this)" class="date" size="11"
			readonly="readonly" /> (dd/mm/yyyy)</td>
	</tr>
	<tr>
		<td><spring:message code="Dose" /></td>
		<td><input id="ddose" type="text" name="dose" size="5" /></td>
	</tr>
	<tr>
		<td><spring:message code="Quantity" /></td>
		<td><input id="dquantity" type="text" name="quantity" /></td>
	</tr>
	<tr>
		<td>Dose Units</td>
		<td>
			<select name="units" id="dunits">
				<c:forEach items="${model.doseUnits}" var="dose">
					<option value="${dose.concept.uuid}">${dose.name}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td><spring:message code="Quantity Units" /></td>
		<td>
			<select name="quantityUnits" id="dquantityunits">
				<c:forEach items="${model.quantityUnits}" var="dQtyU">
					<option value="${dQtyU.concept.uuid}">${dQtyU.name}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td>Drug Route</td>
		<td>
			<select name="drugRoute" id="dRoute">
				<c:forEach items="${model.drugRoutes}" var="dRoute">
					<option value="${dRoute.concept.uuid}">${dRoute.name}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td valign="top"><spring:message code="@MODULE_ID@.instructions" /></td>
		<td><textarea name="instructions" cols="50" rows="4"
			id="dinstructions"></textarea></td>
	</tr>

	<tr>
		<td><input type="submit" value="Submit" class="send" /></td>
	</tr>
</table>

</form>
</div>

<div id="stop-modal-content">
<form method="post" action="module/@MODULE_ID@/dopc.form?patientId=${model.patientId}">
<input type="hidden" name="orderId" id="stopping" /> <input
	type="hidden" name="stopping" id="stop" />
<table>
	<tr>
		<td><spring:message code="pharmacymanagement.stopReason" /></td>
		<td><select name="reasons" id="stopReasonId">
			<c:forEach items="${model.reasonStoppedOptions}" var="sr">
				<option value="${sr.key}">${sr.value}</option>
			</c:forEach>
		</select></td>
	</tr>

	<tr>
		<td><spring:message code="pharmacymanagement.stopDate" /></td>
		<td><input id="cal" type="text" name="stopDate" size="12" id="stopDateId"
			onfocus="showCalendar(this)" class="date" size="11" /></td>
	</tr>
	<tr>
		<td><input type="submit" value="Update" class="send" /></td>
	</tr>
</table>

</form>
<br />
</div>

<div id="ordonance-modal-content" style="display: none">
<img id="print_button" src="${pageContext.request.contextPath}/images/printer.gif" style="cursor:pointer;" title="Print"/>
<div class="printArea">
<div id="ordonnanceModal" style="font-size: 10px;">
<center><u><h3>MEDICAL PRESCRIPTION</h3></u>
<table width="600" border="0" style="font-size: 10px;">
  <tr>
    <td width="83">Medical Center</td>
    <td width="411">: ${model.dftLoc.name}</td>
    <td width="40">&nbsp;</td>
    <td width="164">&nbsp;</td>
  </tr>
  <tr>
    <td>Insurance type</td>
    <td>: ${empty model.insuranceType ? 'None' : model.insuranceType}</td>
    <td>Id No</td>
    <td>: ${empty model.insuranceNumber ? 'None' : model.insuranceNumber}</td>
  </tr>
  <tr>
    <td>Names</td>
    <td>: ${model.patient.familyName} ${model.patient.middleName} ${model.patient.givenName}</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<br />
<table width="600" border="1" cellpadding="0" cellspacing="0"  style="font-size: 10px;">
  <tr align="center" style="background-color:#8FABC7; font-weight:bold;">
    <td height="30" colspan="4">PRESCRIPTION</td>
    <td colspan="3">DISPENSATION (BY PHARMACY)</td>
  </tr>
  <tr align="center" style="background-color:#8FABC7; font-weight:bold;">
    <td height="30">Drug</td>
    <td>Dosage</td>
    <td width="80">Units</td>
    <td width="90">Frequency</td>
    <td width="39" height="24">QTY</td>
    <td width="62">U.P</td>
    <td>T.P</td>
  </tr>
  <tr id="presc-drugs1"></tr>
  <tr id="presc-drugs2"></tr>
  <tr id="presc-drugs3"></tr>
  <tr id="presc-drugs4"></tr>
  <tr>
    <td colspan="4" rowspan="3" valign="middle" style="background-color:#E5E5FF;"><p>Medical Doctor Names: ${model.provider.familyName} ${model.provider.firstName}</p>
      <p>Stamp, signature and date.</p>
      <p>&nbsp;</p></td>
    <td height="30%" colspan="2" align="center" style="background-color:#E5E5FF;"><strong>Total</strong></td>
    <td width="87" style="background-color:#E5E5FF;">&nbsp;</td>
  </tr>
  <tr height="30%" style="background-color:#E5E5FF;">
    <td colspan="2" align="center"><strong>Client</strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr height="30%" style="background-color:#E5E5FF;">
    <td colspan="2" align="center"><strong>Assurance</strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr style="background-color:#E5E5FF;">
    <td colspan="4" valign="middle"><p><strong><em>Reception</em></strong></p>
      <p>Names, signature and date</p>
      <p>&nbsp;</p></td>
    <td height="68" colspan="3" align="left" valign="middle"><p><em><strong>Delivery</strong></em></p>
      <p>Names, signature and date</p>
      <p>&nbsp;</p></td>
    </tr>
</table>
</center>
</div>	
</div>
</div>

<!-- delete order modal -->
<div id="delete-modal-content">
<form method="post" action="module/@MODULE_ID@/dopc.form?patientId=${model.patientId}&delete=on">
<input type="hidden" name="orderToDel" id="orderToDelId" />
<select name="deleteReason" id="deleteReasonId">
<option value="Date Error">Date Error</option>
<option value="Error">Error</option>
<option value="Other">Other</option>
</select>
<input type="submit" value="Delete" />
</form>
</div>
