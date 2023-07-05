<!DOCTYPE html>
<html>
<head>
	<title>Insert a new data</title>
</head>
<body>
	<div class="container mt-5">
		<h1>Insert a new data</h1>
		<form name="insertDataForm" id="insertDataForm" onSubmit="Javascript:insertData()">
			<div class="mb-3">
				<label for="name" class="form-label">Data name</label>
				<input type="text" class="form-control" id="name" name="name" required>
			</div>
			<div class="mb-3">
				<label for="description" class="form-label">Description</label>
				<textarea class="form-control" id="description" name="description" required></textarea>
			</div>
			<div class="mb-3">
				<label for="data" class="form-label">Data</label>
				<input name="data" id="data-file" type="file" required>
			</div>
			<button name="" type="submit" value="Inserisci il dato" class="btn btn-primary">Insert data</button>
		</form>
	</div>
</body>
</html>