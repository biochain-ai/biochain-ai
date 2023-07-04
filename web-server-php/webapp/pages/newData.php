<!DOCTYPE html>
<html>
<head>
	<title>Insert a new data</title>
</head>
<body>
	<div class="container mt-5">
		<h1>Insert a new data</h1>
		<form method="post" action="process.php">
			<div class="mb-3">
				<label for="data_name" class="form-label">Data name</label>
				<input type="text" class="form-control" id="data_name" name="data_name" required>
			</div>
			<div class="mb-3">
				<label for="description" class="form-label">Description</label>
				<textarea class="form-control" id="description" name="description" required></textarea>
			</div>
			<div class="mb-3">
				<label for="data" class="form-label">Data</label>
				<input type="text" class="form-control" id="data" name="data" required>
			</div>
			<button type="submit" class="btn btn-primary">Submit</button>
		</form>
	</div>
</body>
</html>