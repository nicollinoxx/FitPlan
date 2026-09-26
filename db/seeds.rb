# Development data: a few users with avatars, workout and diet sheets, follows,
# a pending sheet share and a week of completions, so every screen (and every
# tab in the mobile apps) has something to show.
#
# Idempotent: each user and their content are only created the first time, and
# a user gets an avatar only while they have none.
# Sign in with any of the emails below and the password "password123".

return unless Rails.env.development?

require "vips"

PASSWORD = "password123"

def seed_user(email:, name:)
  user = User.find_by(email: email)
  return [ user, false ] if user

  [ User.create!(email: email, name: name, password: PASSWORD, verified: true), true ]
end

# A 256x256 PNG with the user's initials on a solid color, drawn with libvips
# (already used by Active Storage), so no image files live in the repository.
def seed_avatar(user, color)
  return if user.avatar.attached?

  size     = 256
  initials = user.name.split.map(&:first).first(2).join.upcase
  text     = Vips::Image.text(initials, font: "sans bold 96")
  mask     = text.embed((size - text.width) / 2, (size - text.height) / 2, size, size)

  background = (Vips::Image.black(size, size, bands: 3) + color).cast(:uchar)
  foreground = (Vips::Image.black(size, size, bands: 3) + 255).cast(:uchar)
  png        = mask.ifthenelse(foreground, background, blend: true).write_to_buffer(".png")

  user.avatar.attach(io: StringIO.new(png), filename: "#{user.handle}.png", content_type: "image/png")
end

def seed_workout_sheet(user, name, description, exercises)
  user.sheets.create!(name: name, description: description, sheet_type: "workout").tap do |sheet|
    exercises.each do |exercise, series, repetitions, charge, interval|
      sheet.workouts.create!(exercise: exercise, series: series, repetitions: repetitions, charge: charge, interval: interval)
    end
  end
end

def seed_diet_sheet(user, name, description, meals)
  user.sheets.create!(name: name, description: description, sheet_type: "diet").tap do |sheet|
    meals.each do |meal, protein, carbohydrate, fat|
      sheet.diets.create!(meal: meal, protein_g: protein, carbohydrate_g: carbohydrate, fat_g: fat)
    end
  end
end

tester, tester_created = seed_user(email: "tester@fitplan.dev", name: "Tester")
ana,    ana_created    = seed_user(email: "ana@fitplan.dev",    name: "Ana Souza")
bruno,  bruno_created  = seed_user(email: "bruno@fitplan.dev",  name: "Bruno Lima")

seed_avatar(tester, [ 0, 112, 60 ])
seed_avatar(ana,    [ 255, 107, 53 ])
seed_avatar(bruno,  [ 13, 110, 253 ])

if tester_created
  tester.create_healthy_metric!(gender: "male", birth_date: Date.new(1995, 4, 12), height: 1.78, weight: 80)

  chest = seed_workout_sheet(tester, "Workout A - Chest and Triceps", "Monday and Thursday", [
    [ "Bench press",            4, "10", "60kg", 90 ],
    [ "Incline dumbbell press", 3, "12", "22kg", 60 ],
    [ "Dumbbell fly",           3, "12", "14kg", 60 ],
    [ "Triceps rope pushdown",  4, "15", "25kg", 45 ]
  ])

  back = seed_workout_sheet(tester, "Workout B - Back and Biceps", "Tuesday and Friday", [
    [ "Lat pulldown",           4, "10", "55kg", 90 ],
    [ "Bent-over row",          4, "10", "40kg", 90 ],
    [ "Barbell curl",           3, "12", "12kg", 60 ]
  ])

  seed_workout_sheet(tester, "Workout C - Legs", "Wednesday and Saturday", [
    [ "Back squat",             4, "8-10", "80kg", 120 ],
    [ "Leg press",              4, "12",   "180kg", 90 ],
    [ "Leg extension",          3, "15",   "40kg", 60 ],
    [ "Standing calf raise",    4, "20",   "60kg", 45 ]
  ])

  seed_diet_sheet(tester, "Diet - Muscle gain", "About 2,800 kcal", [
    [ "Breakfast: eggs, whole wheat bread and banana", 30, 60, 15 ],
    [ "Lunch: rice, beans, chicken and salad",         45, 80, 12 ],
    [ "Snack: yogurt with oats",                       20, 40,  6 ],
    [ "Dinner: sweet potato and lean beef",            40, 50, 10 ]
  ])

  seed_diet_sheet(tester, "Diet - Rest day", "Lower carbs", [
    [ "Breakfast: omelette and avocado", 28, 10, 20 ],
    [ "Lunch: fish and vegetables",      40, 25, 12 ]
  ])

  # A week of finished workouts up to today, for the dashboard, streak and rankings.
  6.downto(0) do |days_ago|
    sheet = days_ago.even? ? chest : back
    sheet.sheet_completions.create!(user: tester, completed_at: days_ago.days.ago)
  end
end

if ana_created
  ana.create_healthy_metric!(gender: "female", birth_date: Date.new(1998, 9, 3), height: 1.65, weight: 60)

  seed_workout_sheet(ana, "Functional - Full body", "Three times a week", [
    [ "Burpee",           4, "15",  "bodyweight", 30 ],
    [ "Kettlebell swing", 4, "20",  "16kg",       45 ],
    [ "Plank",            3, "45s", "bodyweight", 30 ]
  ])

  seed_diet_sheet(ana, "Diet - Cutting", "About 1,700 kcal", [
    [ "Breakfast: tapioca with cheese", 20, 35, 8 ],
    [ "Lunch: salmon and quinoa",       35, 40, 14 ]
  ])
end

if bruno_created
  seed_workout_sheet(bruno, "Running - 5K", "Race preparation", [
    [ "Warm-up",        1, "10 min", "easy",  0 ],
    [ "400m repeats",   6, "1",      "hard", 90 ],
    [ "Cool-down",      1, "10 min", "easy",  0 ]
  ])
end

# Social: everyone follows the tester, and the tester follows Ana back.
[ [ ana, tester ], [ bruno, tester ], [ tester, ana ] ].each do |follower, followed|
  Follow.find_or_create_by!(follower: follower, followed: followed)
end

# A pending share from Ana, so the tester has something to accept in the Shares tab.
unless SheetShare.exists?(sender: ana, recipient: tester)
  SheetShare.create_with_requests(sender: ana, recipient: tester, sheet_ids: ana.sheets.ids)
end

puts "Seeded #{User.count} users and #{Sheet.count} sheets. Sign in as tester@fitplan.dev / #{PASSWORD}"
