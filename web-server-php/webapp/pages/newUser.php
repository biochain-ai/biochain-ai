<!DOCTYPE html>
<html>
<head>
	<title>Insert a new user</title>
</head>
<body>
	<div class="container mt-5">
		<h1>Insert a new user</h1>
		<form method="post" action="process.php">
			<div class="mb-3">
				<label for="mail" class="form-label">Mail</label>
				<input type="email" class="form-control" id="mail" name="mail" required>
			</div>
			<div class="mb-3">
				<label for="name" class="form-label">Name</label>
				<input type="text" class="form-control" id="name" name="name" required>
			</div>
			<div class="mb-3">
				<label for="organization" class="form-label">Organization</label>
				<input type="text" class="form-control" id="organization" name="organization" required>
			</div>
			<button type="submit" class="btn btn-primary">Submit</button>
		</form>
	</div>
</body>
</html>